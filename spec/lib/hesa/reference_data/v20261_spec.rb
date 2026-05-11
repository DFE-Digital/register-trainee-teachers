# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hesa::ReferenceData::V20261 do
  describe "TYPES" do
    it "extends V20260::TYPES with iqts_country" do
      expect(described_class::TYPES).to eq(
        Hesa::ReferenceData::V20260::TYPES.merge(iqts_country: ReferenceData::COUNTRIES),
      )
    end
  end

  describe "iqts_country" do
    let(:rows) { CSV.parse(described_class.find(:iqts_country).as_csv, headers: true) }

    it "produces a CSV mirroring the country reference data" do
      expect(rows).not_to be_empty
      expect(rows.headers).to eq(%w[Code Label])
    end
  end
end
