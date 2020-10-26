require "rails_helper"

module Diversities
  describe EthnicGroup do
    let(:trainee) { build(:trainee) }

    subject { described_class.new(trainee: trainee) }

    describe "validations" do
      it { is_expected.to validate_presence_of(:ethnic_group) }
      it { is_expected.to validate_inclusion_of(:ethnic_group).in_array(Trainee.ethnic_groups.keys) }
    end
  end
end
