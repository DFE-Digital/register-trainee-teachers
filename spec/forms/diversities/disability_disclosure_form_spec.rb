# frozen_string_literal: true

require "rails_helper"

module Diversities
  describe DisabilityDisclosureForm, type: :model do
    let(:trainee) { build(:trainee) }

    subject { described_class.new(trainee: trainee) }

    describe "validations" do
      it { is_expected.to validate_presence_of(:disability_disclosure) }

      it do
        is_expected.to validate_inclusion_of(:disability_disclosure).in_array(
          Diversities::DISABILITY_DISCLOSURE_ENUMS.values,
        )
      end
    end
  end
end
