# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::TraineeAttributes, type: :model do
  subject { described_class.new }

  Api::TraineeAttributes::ATTRIBUTES.each do |attribute|
    it "validates presence of #{attribute}" do
      subject.valid?
      expect(subject.errors.details[attribute]).to include(error: :blank)
    end
  end

  it "validates length of first_names" do
    subject.first_names = 'a' * 51
    subject.valid?
    expect(subject.errors.details[:first_names]).to include(error: :too_long, count: 50)
  end

  it "validates length of last_name" do
    subject.last_name = 'a' * 51
    subject.valid?
    expect(subject.errors.details[:last_name]).to include(error: :too_long, count: 50)
  end

  it "validates length of middle_names" do
    subject.middle_names = 'a' * 51
    subject.valid?
    expect(subject.errors.details[:middle_names]).to include(error: :too_long, count: 50)
  end

  it "validates date_of_birth with DateOfBirthValidator" do
    subject.date_of_birth = Time.zone.today + 1.day
    subject.valid?
    expect(subject.errors.details[:date_of_birth]).to include(error: :future)
  end

  it "validates inclusion of sex in Trainee.sexes.keys" do
    invalid_sex = 'invalid'
    subject.sex = invalid_sex
    subject.valid?
    expect(subject.errors.details[:sex]).to include(error: :inclusion, value: invalid_sex)
  end
end
