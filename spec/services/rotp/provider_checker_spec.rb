# frozen_string_literal: true

require "rails_helper"

module Rotp
  RSpec.describe ProviderChecker, type: :service do
    describe "provider comparison" do
      before do
        allow(Rotp::Providers).to receive(:list).and_return(rotp_data)
      end

      subject { described_class.new }

      let(:accredited_provider) { create(:provider) }
      let(:training_partner) { create(:training_partner, :hei) }
      let(:school_partner) { create(:training_partner, :school) }

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

      let(:rotp_school_matched) do
        { "urn" => school_partner.urn, "operating_name" => "Matched School", "accreditation_status" => "unaccredited", "provider_type" => "school" }
      end

      let(:rotp_school_missing) do
        { "urn" => "999999", "operating_name" => "Unknown School", "accreditation_status" => "unaccredited", "provider_type" => "school" }
      end

      let(:rotp_data) { [rotp_accredited_matched, rotp_accredited_missing, rotp_tp_matched, rotp_tp_missing, rotp_school_matched, rotp_school_missing] }

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

      it "matches school partners by urn" do
        expect(subject.school_matched).to contain_exactly(rotp_school_matched)
      end

      it "identifies school partners in RoTP but not Register" do
        expect(subject.school_missing_from_register).to contain_exactly(rotp_school_missing)
      end

      it "reports any_discrepancies? when there are missing providers" do
        expect(subject.any_discrepancies?).to be true
      end

      context "when everything matches" do
        let(:rotp_data) { [rotp_accredited_matched, rotp_tp_matched, rotp_school_matched] }

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

      context "when Register includes the DfE / GP provider" do
        let(:dfe_gp) { create(:provider, name: "DfE", code: "GP") }
        let(:rotp_gp) { { "code" => "GP", "operating_name" => "DfE", "accreditation_status" => "accredited", "provider_type" => "hei" } }
        let(:rotp_data) { [rotp_accredited_matched, rotp_gp] }

        before { dfe_gp }

        it "excludes it from both matched and missing lists" do
          expect(subject.accredited_matched.map { |p| p["code"] }).not_to include("GP")
          expect(subject.accredited_missing_from_rotp.map { |p| p["code"] }).not_to include("GP")
          expect(subject.accredited_missing_from_register.map { |p| p["code"] }).to include("GP")
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

      context "when a Register school partner has no match in RoTP" do
        let(:extra_school) { create(:training_partner, :school) }
        let(:rotp_data) { [rotp_school_matched] }

        before { extra_school }

        it "includes the unmatched school partner in school_missing_from_rotp" do
          missing_urns = subject.school_missing_from_rotp.map { |p| p["urn"] }
          expect(missing_urns).to include(extra_school.urn)
        end
      end
    end
  end
end
