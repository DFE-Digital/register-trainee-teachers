# frozen_string_literal: true

require "rails_helper"

module Rotp
  RSpec.describe ProviderCheckerCsvExport, type: :service do
    subject(:csv_output) { described_class.call(checker) }

    let(:accredited_matched) { { "operating_name" => "Alpha University", "code" => "A01", "urn" => nil, "accreditation_status" => "accredited", "provider_type" => "hei" } }
    let(:accredited_missing_from_register) { { "operating_name" => "Beta College", "code" => "B02", "urn" => nil, "accreditation_status" => "accredited", "provider_type" => "scitt" } }
    let(:accredited_missing_from_rotp) { { "operating_name" => "Gamma Institute", "code" => "G03", "urn" => nil, "accreditation_status" => nil, "provider_type" => nil } }
    let(:training_partner_matched) { { "operating_name" => "Delta SCITT", "code" => "D04", "urn" => nil, "accreditation_status" => "unaccredited", "provider_type" => "scitt" } }
    let(:training_partner_missing_from_register) { { "operating_name" => "Epsilon HEI", "code" => "E05", "urn" => nil, "accreditation_status" => "unaccredited", "provider_type" => "hei" } }
    let(:training_partner_missing_from_rotp) { { "operating_name" => "Zeta College", "code" => "Z06", "urn" => nil, "accreditation_status" => nil, "provider_type" => nil } }
    let(:school_matched) { { "operating_name" => "Eta School", "code" => nil, "urn" => "100001", "accreditation_status" => "unaccredited", "provider_type" => "school" } }
    let(:school_missing_from_register) { { "operating_name" => "Theta School", "code" => nil, "urn" => "100002", "accreditation_status" => "unaccredited", "provider_type" => "school" } }
    let(:school_missing_from_rotp) { { "operating_name" => "Iota School", "code" => nil, "urn" => "100003", "accreditation_status" => nil, "provider_type" => nil } }

    let(:checker) do
      instance_double(
        Rotp::ProviderChecker,
        accredited_matched: [accredited_matched],
        accredited_missing_from_register: [accredited_missing_from_register],
        accredited_missing_from_rotp: [accredited_missing_from_rotp],
        training_partner_matched: [training_partner_matched],
        training_partner_missing_from_register: [training_partner_missing_from_register],
        training_partner_missing_from_rotp: [training_partner_missing_from_rotp],
        school_matched: [school_matched],
        school_missing_from_register: [school_missing_from_register],
        school_missing_from_rotp: [school_missing_from_rotp],
      )
    end

    let(:rows) { CSV.parse(csv_output, headers: true) }

    it "includes the correct headers" do
      expect(rows.headers).to eq(%w[comparison_group status operating_name code urn accreditation_status provider_type])
    end

    it "produces a row for each result set entry" do
      expect(rows.count).to eq(9)
    end

    it "labels accredited matched rows correctly" do
      row = rows.find { |r| r["operating_name"] == "Alpha University" }
      expect(row["comparison_group"]).to eq("accredited")
      expect(row["status"]).to eq("matched")
      expect(row["code"]).to eq('="A01"')
    end

    it "labels accredited missing_from_register rows correctly" do
      row = rows.find { |r| r["operating_name"] == "Beta College" }
      expect(row["comparison_group"]).to eq("accredited")
      expect(row["status"]).to eq("missing_from_register")
    end

    it "labels accredited missing_from_rotp rows correctly" do
      row = rows.find { |r| r["operating_name"] == "Gamma Institute" }
      expect(row["comparison_group"]).to eq("accredited")
      expect(row["status"]).to eq("missing_from_rotp")
    end

    it "labels training_partner matched rows correctly (including schools)" do
      tp_row = rows.find { |r| r["operating_name"] == "Delta SCITT" }
      school_row = rows.find { |r| r["operating_name"] == "Eta School" }

      expect(tp_row["comparison_group"]).to eq("training_partner")
      expect(tp_row["status"]).to eq("matched")
      expect(school_row["comparison_group"]).to eq("training_partner")
      expect(school_row["status"]).to eq("matched")
    end

    it "labels training_partner missing_from_register rows correctly (including schools)" do
      tp_row = rows.find { |r| r["operating_name"] == "Epsilon HEI" }
      school_row = rows.find { |r| r["operating_name"] == "Theta School" }

      expect(tp_row["comparison_group"]).to eq("training_partner")
      expect(tp_row["status"]).to eq("missing_from_register")
      expect(school_row["comparison_group"]).to eq("training_partner")
      expect(school_row["status"]).to eq("missing_from_register")
    end

    it "labels training_partner missing_from_rotp rows correctly (including schools)" do
      tp_row = rows.find { |r| r["operating_name"] == "Zeta College" }
      school_row = rows.find { |r| r["operating_name"] == "Iota School" }

      expect(tp_row["comparison_group"]).to eq("training_partner")
      expect(tp_row["status"]).to eq("missing_from_rotp")
      expect(school_row["comparison_group"]).to eq("training_partner")
      expect(school_row["status"]).to eq("missing_from_rotp")
    end

    it "wraps code and urn in spreadsheet text formula to prevent numeric coercion" do
      row = rows.find { |r| r["operating_name"] == "Eta School" }
      expect(row["urn"]).to eq('="100001"')
      expect(rows.find { |r| r["operating_name"] == "Alpha University" }["code"]).to eq('="A01"')
    end
  end
end
