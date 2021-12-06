# frozen_string_literal: true

RSpec.shared_examples "start date validations" do
  context "when date is in the future" do
    let(:trainee) do
      build(:trainee, course_start_date: Time.zone.today, course_end_date: 1.year.from_now)
    end
    let(:future_date) { 1.month.from_now }

    let(:params) { { day: future_date.day, month: future_date.month, year: future_date.year, commencement_status: "itt_started_later" } }

    it "is invalid" do
      expect(subject.errors[:commencement_date]).to include("Trainee start date must be in the past")
    end
  end
end
