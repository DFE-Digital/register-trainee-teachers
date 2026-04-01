# frozen_string_literal: true

require "rails_helper"

module Rotp
  RSpec.describe ProviderChecker, type: :service do
    describe "#call" do
      before do
        allow(Rotp::Client).to receive(:get).and_return(double(parsed_response: { "data" => rotp_data }))
      end

      subject { described_class.call }

      let(:accredited_provider) { create(:provider) }
      let(:training_partner) { create(:training_partner, :hei) }

      let(:rotp_accredited_matched) do
        { "code" => accredited_provider.code, "operating_name" => "Matched HEI", "accreditation_status" => "accredited", "provider_type" => "hei" }
      end

      let(:rotp_accredited_missing) do
        { "code" => "ZZZ", "operating_name" => "Unknown HEI", "accreditation_status" => "accredited", "provider_type" => "hei" }
      end

      let(:rotp_tp_matched) do
        { "code" => training_partner.provider.code, "operating_name" => "Matched TP", "accreditation_status" => "unaccredited", "provider_type" => "scitt" }
      end

      let(:rotp_tp_missing) do
        { "code" => "YYY", "operating_name" => "Unknown TP", "accreditation_status" => "unaccredited", "provider_type" => "hei" }
      end

      let(:rotp_school) do
        { "code" => "XXX", "operating_name" => "Some School", "accreditation_status" => "unaccredited", "provider_type" => "school" }
      end

      let(:rotp_data) { [rotp_accredited_matched, rotp_accredited_missing, rotp_tp_matched, rotp_tp_missing, rotp_school] }

      it "matches accredited providers by code" do
        expect(subject.accredited_matched).to contain_exactly(rotp_accredited_matched)
      end

      it "identifies accredited providers in RoTP but not Register" do
        expect(subject.accredited_missing_from_register).to contain_exactly(rotp_accredited_missing)
      end

      it "identifies accredited providers in Register but not RoTP" do
        missing_codes = subject.accredited_missing_from_rotp.map { |p| p["code"] }
        expect(missing_codes).not_to include(accredited_provider.code)
      end

      it "matches training partners by provider code" do
        expect(subject.training_partner_matched).to contain_exactly(rotp_tp_matched)
      end

      it "identifies training partners in RoTP but not Register" do
        expect(subject.training_partner_missing_from_register).to contain_exactly(rotp_tp_missing)
      end

      it "skips school-type providers" do
        expect(subject.skipped_schools).to contain_exactly(rotp_school)
      end

      it "reports any_discrepancies? when there are missing providers" do
        expect(subject.any_discrepancies?).to be true
      end

      context "when everything matches" do
        let(:rotp_data) { [rotp_accredited_matched, rotp_tp_matched] }

        it "reports no discrepancies" do
          expect(subject.any_discrepancies?).to be false
        end
      end

      context "when a Register provider has no match in RoTP" do
        let(:extra_provider) { create(:provider) }
        let(:rotp_data) { [rotp_accredited_matched] }

        before { extra_provider }

        it "includes the unmatched Register provider in accredited_missing_from_rotp" do
          missing_codes = subject.accredited_missing_from_rotp.map { |p| p["code"] }
          expect(missing_codes).to include(extra_provider.code)
        end
      end

      context "when a Register training partner has no match in RoTP" do
        let(:extra_tp) { create(:training_partner, :scitt) }
        let(:rotp_data) { [rotp_tp_matched] }

        before { extra_tp }

        it "includes the unmatched training partner in training_partner_missing_from_rotp" do
          missing_codes = subject.training_partner_missing_from_rotp.map { |p| p["code"] }
          expect(missing_codes).to include(extra_tp.provider.code)
        end
      end
    end
  end
end
