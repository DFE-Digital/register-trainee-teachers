require "rails_helper"

describe Nationality do
  subject { build(:nationality) }

  describe "associations" do
    it { is_expected.to have_many(:nationalisations).inverse_of(:nationality) }
    it { is_expected.to have_many(:trainees).through(:nationalisations) }
  end
end
