# frozen_string_literal: true

require "rails_helper"

module Rotp
  describe ProviderCheckerJob do
    include ActiveJob::TestHelper

    let(:result) do
      instance_double(
        Rotp::ProviderChecker,
        accredited_matched: [],
        accredited_missing_from_register: [],
        accredited_missing_from_rotp: [],
        training_partner_matched: [],
        training_partner_missing_from_register: [],
        training_partner_missing_from_rotp: [],
        skipped_schools: [],
        any_discrepancies?: false,
      )
    end

    before do
      allow(Rotp::ProviderChecker).to receive(:new).and_return(result)
      allow(TeamsNotifierService).to receive(:call).and_return(true)
      allow(Rails.env).to receive(:production?).and_return(true)
    end

    it "sends a message to Teams" do
      described_class.perform_now
      expect(TeamsNotifierService).to have_received(:call).with(hash_including(:title, :message, :icon_emoji))
    end

    context "when there are no discrepancies" do
      before do
        allow(result).to receive_messages(
          accredited_matched: [1, 2],
          accredited_missing_from_register: [],
          accredited_missing_from_rotp: [],
          training_partner_matched: [3],
          training_partner_missing_from_register: [],
          training_partner_missing_from_rotp: [],
          skipped_schools: [],
          any_discrepancies?: false,
        )
      end

      it "sends a clean report to Teams with a success icon" do
        described_class.perform_now
        expect(TeamsNotifierService).to have_received(:call).with(
          title: include("RoTP Provider Checker Results"),
          message: include(
            "Matched: 2",
            "In RoTP but not Register: 0",
            "In Register but not RoTP: 0",
            "Matched: 1",
          ),
          icon_emoji: "✅",
        )
      end
    end

    context "when there are discrepancies" do
      let(:missing_accredited) do
        { "operating_name" => "Unknown University", "code" => "Z99" }
      end

      let(:missing_tp) do
        { "operating_name" => "Unknown SCITT", "code" => "Y88" }
      end

      before do
        allow(result).to receive_messages(
          accredited_matched: [1],
          accredited_missing_from_register: [missing_accredited],
          accredited_missing_from_rotp: [],
          training_partner_matched: [],
          training_partner_missing_from_register: [missing_tp],
          training_partner_missing_from_rotp: [],
          skipped_schools: [1, 2],
          any_discrepancies?: true,
        )
      end

      it "includes discrepancy details and an alert icon" do
        described_class.perform_now
        expect(TeamsNotifierService).to have_received(:call).with(
          title: include("RoTP Provider Checker Results"),
          message: include(
            "In RoTP but not Register: 1",
            "Unknown University (Z99)",
            "Unknown SCITT (Y88)",
            "Not checked:** 2 school training partners",
          ),
          icon_emoji: "🚨",
        )
      end
    end

    context "when not in production" do
      before do
        allow(Rails.env).to receive(:production?).and_return(false)
      end

      it "does not run" do
        expect(described_class.perform_now).to be false
        expect(TeamsNotifierService).not_to have_received(:call)
      end
    end
  end
end
