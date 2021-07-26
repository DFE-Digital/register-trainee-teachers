# frozen_string_literal: true

RSpec.shared_examples "date is not before course start date" do |form|
  context "date is before the course start date" do
    before do
      subject.year = trainee.course_start_date.year - 1
      subject.validate
    end

    it "is invalid" do
      expect(subject.errors[:date]).to include(I18n.t("activemodel.errors.models.#{form}.attributes.date.not_before_course_start_date"))
    end
  end
end
