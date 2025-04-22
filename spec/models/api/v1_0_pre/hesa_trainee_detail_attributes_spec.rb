# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V10Pre::HesaTraineeDetailAttributes do
  subject { described_class }

  it { is_expected.to be < Api::V01::HesaTraineeDetailAttributes }

  describe "validations" do
    it "uses the RulesValidator" do
      expect(described_class.validators.map(&:class)).to include(
        Api::V10Pre::HesaTraineeDetailAttributes::RulesValidator,
      )
    end
  end
end
