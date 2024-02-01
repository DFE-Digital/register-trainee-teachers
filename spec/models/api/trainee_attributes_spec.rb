# spec/models/trainee_attributes_spec.rb
require 'rails_helper'

RSpec.describe Api::TraineeAttributes, type: :model do
  subject { described_class.new }

  Api::TraineeAttributes::ATTRIBUTES.each do |attribute|
    it "validates presence of #{attribute}" do
      subject.valid?
      expect(subject.errors.details[attribute]).to include(error: :blank)
    end
  end
end
