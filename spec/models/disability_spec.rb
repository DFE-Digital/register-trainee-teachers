require "rails_helper"

describe Disability do
  subject { build(:disability) }

  describe "associations" do
    it { is_expected.to have_many(:trainee_disabilities).inverse_of(:disability) }
    it { is_expected.to have_many(:trainees).through(:trainee_disabilities) }
  end
end
