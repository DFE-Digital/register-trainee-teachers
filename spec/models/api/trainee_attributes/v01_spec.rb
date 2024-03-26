# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::TraineeAttributes::V01 do
  subject { described_class.new }

  Api::TraineeAttributes::V01::REQUIRED_ATTRIBUTES.each do |attribute|
    it "validates presence of #{attribute}" do
      subject.valid?
      expect(subject.errors.details[attribute]).to include(error: :blank)
    end
  end

  it "derives course_allocation_subject from course_subject_one_name before validation" do
    subject.course_subject_one = "biology"
    create(:subject_specialism, name: subject.course_subject_one)
    subject.valid?
    expect(subject.course_allocation_subject_id).to be_present
  end
end
