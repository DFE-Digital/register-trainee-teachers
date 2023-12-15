# spec/models/application_record_spec.rb

require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  let(:test_model) { User.new(first_name: 'd' * 256) }

  describe '#apply_character_limits' do
    it 'adds an error when a string column exceeds the character limit' do
      test_model.valid?
      expect(test_model.errors[:first_name]).to include('is too long (maximum is 255 characters)')
    end
  end
end
