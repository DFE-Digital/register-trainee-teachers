# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hesa::ReferenceData::V20260 do
  include FileHelper

  describe "as_csv" do
    it "converts data to csv" do
      expect(
        CSV.parse(described_class.find(:course_age_range).as_csv),
      ).to eq(
        CSV.parse(file_content("reference_data/v2026_0/course_age_range.csv")),
      )
    end

    describe "training_initiative" do
      let(:rows) { CSV.parse(described_class.find(:training_initiative).as_csv, headers: true) }

      it "excludes entries that have no hesa code" do
        expect(rows.map { |r| r["Code"] }).to all(be_present)
        expect(rows.map { |r| r["Label"] }).not_to include(
          "Future Teaching Scholars",
          "Troops to Teachers",
          "Not on a training initiative",
          "Veteran teaching undergraduate bursary",
          "Abridged ITT course",
          "Additional ITT place for PE with a priority subject",
        )
      end

      it "uses the locale label when one exists for the hesa code" do
        labels = rows.to_h { |r| [r["Code"], r["Label"]] }
        expect(labels["009"]).to eq("Maths and Physics Chairs Programme")
      end

      it "falls back to display_name when the locale has no entry for the hesa code" do
        labels = rows.to_h { |r| [r["Code"], r["Label"]] }
        expect(labels["011"]).to eq("Primary mathematics specialist")
      end
    end

    describe "institution" do
      let(:rows) { CSV.parse(described_class.find(:institution).as_csv, headers: true) }

      it "excludes entries with a blank hesa code" do
        expect(rows.map { |r| r["Code"] }).to all(be_present)
        expect(rows.map { |r| r["Label"] }).not_to include(
          "Non EU countries",
          "Other EU countries",
          "Other UK (Northern Ireland)",
        )
      end

      it "renders duplicate hesa codes as separate rows sharing the locale label" do
        rows_for_0115 = rows.select { |r| r["Code"] == "0115" }
        rows_for_0204 = rows.select { |r| r["Code"] == "0204" }
        expect(rows_for_0115.size).to eq(2)
        expect(rows_for_0204.size).to eq(2)
        expect(rows_for_0115.map { |r| r["Label"] }).to all(eq("City, University of London"))
        expect(rows_for_0204.map { |r| r["Label"] }).to all(eq("The University of Manchester"))
      end

      it "uses locale label rather than YAML display_name" do
        winchester = rows.select { |r| r["Code"] == "0021" }
        expect(winchester.map { |r| r["Label"] }).to all(eq("The University of Winchester"))
      end
    end
  end
end
