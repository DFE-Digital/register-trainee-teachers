require "rails_helper"

module Diversities
  describe Disclosure do
    let(:trainee) { build(:trainee) }

    subject { described_class.new(trainee: trainee) }

    describe "validations" do
      it { is_expected.to validate_presence_of(:diversity_disclosure) }
      it { is_expected.to validate_inclusion_of(:diversity_disclosure).in_array(Diversities::DIVERSITY_DISCLOSURE_ENUMS.values) }
    end
  end
end
