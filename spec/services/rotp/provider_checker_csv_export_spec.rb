# frozen_string_literal: true

require "rails_helper"

module Rotp
  RSpec.describe ProviderCheckerCsvExport, type: :service do
    subject(:csv_output) { described_class.call(checker) }

    let(:checker) do
      instance_double(
        Rotp::ProviderChecker,
        accredited_matched: [{ "operating_name" => "Alpha University", "code" => "A01", "urn" => nil, "accreditation_status" => "accredited", "provider_type" => "hei" }],
        accredited_missing_from_register: [{ "operating_name" => "Beta College", "code" => "B02", "urn" => nil, "accreditation_status" => "accredited", "provider_type" => "scitt" }],
        accredited_missing_from_rotp: [{ "operating_name" => "Gamma Institute", "code" => "G03", "urn" => nil, "accreditation_status" => nil, "provider_type" => nil }],
        training_partner_matched: [{ "operating_name" => "Delta SCITT", "code" => "D04", "urn" => nil, "accreditation_status" => "unaccredited", "provider_type" => "scitt" }],
        training_partner_missing_from_register: [{ "operating_name" => "Epsilon HEI", "code" => "E05", "urn" => nil, "accreditation_status" => "unaccredited", "provider_type" => "hei" }],
        training_partner_missing_from_rotp: [{ "operating_name" => "Zeta College", "code" => "Z06", "urn" => nil, "accreditation_status" => nil, "provider_type" => nil }],
        school_matched: [{ "operating_name" => "Eta School", "code" => nil, "urn" => "100001", "accreditation_status" => "unaccredited", "provider_type" => "school" }],
        school_missing_from_register: [{ "operating_name" => "Theta School", "code" => nil, "urn" => "100002", "accreditation_status" => "unaccredited", "provider_type" => "school" }],
        school_missing_from_rotp: [{ "operating_name" => "Iota School", "code" => nil, "urn" => "100003", "accreditation_status" => nil, "provider_type" => nil }],
      )
    end

    let(:rows) { CSV.parse(csv_output, headers: true) }

    it "includes the correct headers" do
      expect(rows.headers).to eq(%w[comparison_group status operating_name code urn accreditation_status provider_type])
    end

    it "assigns correct comparison_group and status for each result set" do
      expect(rows).to include(
        have_attributes(fields: include("accredited", "matched", "Alpha University")),
        have_attributes(fields: include("accredited", "missing_from_register", "Beta College")),
        have_attributes(fields: include("accredited", "missing_from_rotp", "Gamma Institute")),
        have_attributes(fields: include("training_partner", "matched", "Delta SCITT")),
        have_attributes(fields: include("training_partner", "matched", "Eta School")),
        have_attributes(fields: include("training_partner", "missing_from_register", "Epsilon HEI")),
        have_attributes(fields: include("training_partner", "missing_from_register", "Theta School")),
        have_attributes(fields: include("training_partner", "missing_from_rotp", "Zeta College")),
        have_attributes(fields: include("training_partner", "missing_from_rotp", "Iota School")),
      )
    end

    it "wraps code and urn in a spreadsheet text formula to prevent numeric coercion" do
      expect(rows.find { |r| r["operating_name"] == "Alpha University" }["code"]).to eq('="A01"')
      expect(rows.find { |r| r["operating_name"] == "Eta School" }["urn"]).to eq('="100001"')
    end
  end
end
