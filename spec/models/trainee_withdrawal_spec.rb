# frozen_string_literal: true

require "rails_helper"

RSpec.describe TraineeWithdrawal do
  describe "associations" do
    it { is_expected.to belong_to(:trainee) }
    it { is_expected.to have_many(:trainee_withdrawal_reasons).dependent(:destroy) }
  end

  describe "enums" do
    it "defines the correct values for trigger enum" do
      expect(described_class.triggers).to eq("provider" => "provider", "trainee" => "trainee")
    end

    it "defines the correct values for future_interest enum" do
      expect(described_class.future_interests).to eq("yes" => "yes", "no" => "no", "unknown" => "unknown")
    end
  end

  describe "auditing" do
    it { is_expected.to be_audited }
  end
end

