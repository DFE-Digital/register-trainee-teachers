# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ReferenceData::WithdrawalReasons do
  describe ".payload" do
    subject(:payload) { described_class.payload }

    it "includes metadata" do
      expect(payload.fetch(:metadata)).to eq(
        name: "withdrawal_reasons",
        display_name: "Withdrawal reasons",
      )
    end

    it "includes trigger and future interest values" do
      expect(payload.fetch(:triggers)).to match_array(TraineeWithdrawal.triggers.keys)
      expect(payload.fetch(:future_interest)).to match_array(TraineeWithdrawal.future_interests.keys)
    end

    it "includes all provider and trainee reasons" do
      codes_by_trigger = payload.fetch(:entries).group_by { |entry| entry.fetch(:trigger) }

      expect(codes_by_trigger.fetch("provider").pluck(:code)).to eq(WithdrawalReasons::PROVIDER_REASONS)
      expect(codes_by_trigger.fetch("trainee").pluck(:code)).to eq(WithdrawalReasons::TRAINEE_REASONS)
    end

    it "marks another-reason codes as requiring another_reason" do
      another_reason_entries = payload.fetch(:entries).select { |entry| entry.fetch(:code).include?("another_reason") }

      expect(another_reason_entries).to all(include(requires_another_reason: true))
    end

    it "marks safeguarding concerns as requiring safeguarding_concern_reasons" do
      safeguarding_entries = payload.fetch(:entries).select { |entry| entry.fetch(:code) == "safeguarding_concerns" }

      expect(safeguarding_entries).to all(include(requires_safeguarding_concern_reasons: true))
    end

    it "uses locale labels for display names" do
      entry = payload.fetch(:entries).find { |e| e.fetch(:code) == "record_added_in_error" }

      expect(entry.fetch(:display_name)).to eq(
        I18n.t("components.withdrawal_details.reasons.record_added_in_error"),
      )
    end
  end
end
