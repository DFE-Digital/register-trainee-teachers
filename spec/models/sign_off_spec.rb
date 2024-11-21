require 'rails_helper'

RSpec.describe SignOff, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:academic_cycle) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'sign_off_type' do
    it "has the correct values" do
      expected_values = { "performance_profile"=> "performance_profile", "census" => "census" }
      expect(SignOff.sign_off_types).to eq(expected_values)
    end
  end
end
