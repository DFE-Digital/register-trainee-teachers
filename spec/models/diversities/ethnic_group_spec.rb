require "rails_helper"

module Diversities
  describe EthnicGroup do
    let(:trainee) { build(:trainee) }

    subject { described_class.new(trainee: trainee) }

    describe "validations" do
      it { is_expected.to validate_presence_of(:ethnic_group) }
      it { is_expected.to validate_inclusion_of(:ethnic_group).in_array(Diversities::ETHNIC_GROUP_ENUMS.values) }
    end
  end
end
