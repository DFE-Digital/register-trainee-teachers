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

  it "validates inclusion of sex in Trainee.sexes.keys" do
    invalid_sex = "invalid"
    subject.sex = invalid_sex
    subject.valid?
    expect(subject.errors.details[:sex]).to include(error: :inclusion, value: invalid_sex)
  end

  it "derives course_allocation_subject from course_subject_one_name before validation" do
    subject.course_subject_one = "biology"
    create(:subject_specialism, name: subject.course_subject_one)
    subject.valid?
    expect(subject.course_allocation_subject).to be_present
  end
end
