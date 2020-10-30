require "rails_helper"

module Diversities
  describe EthnicBackground do
    let(:trainee) { build(:trainee) }

    subject { described_class.new(trainee: trainee) }

    describe "validations" do
      it { is_expected.to validate_presence_of(:ethnic_background) }
    end
  end
end
