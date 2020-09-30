require "rails_helper"

describe Nationality do
  subject { build(:nationality) }

  describe "associations" do
    it { should have_many(:nationalisations).inverse_of(:nationality) }
    it { should have_many(:trainees).through(:nationalisations) }
  end
end
