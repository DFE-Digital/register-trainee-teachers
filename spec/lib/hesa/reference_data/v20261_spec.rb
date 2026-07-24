# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hesa::ReferenceData::V20261 do
  include FileHelper

  it "inherits from V20250" do
    expect(described_class).to be < Hesa::ReferenceData::V20250
  end

  describe "::entries_for" do
    let(:entries) do
      described_class.entries_for(:training_initiative, ReferenceData::TRAINING_INITIATIVES)
    end

    it "returns rich entries with hesa_code, display_name, start_year, end_year" do
      expect(entries.first.keys).to contain_exactly(:hesa_code, :display_name, :start_year, :end_year)
    end

    it "is sorted by hesa_code" do
      codes = entries.map { |e| e[:hesa_code] }
      expect(codes).to eq(codes.sort)
    end
  end

  describe "TYPES" do
    it "maps every reference data type to its registry" do
      expect(described_class::TYPES).to eq(
        country: ReferenceData::COUNTRIES,
        course_age_range: ReferenceData::COURSE_AGE_RANGES,
        course_subject: ReferenceData::COURSE_SUBJECTS,
        degree_subject: ReferenceData::DEGREE_SUBJECTS,
        degree_grade: ReferenceData::DEGREE_GRADES,
        degree_type: ReferenceData::DEGREE_TYPES,
        disability: ReferenceData::DISABILITIES,
        ethnicity: ReferenceData::ETHNICITIES,
        fund_code: ReferenceData::FUND_CODES,
        funding_method: ReferenceData::FUNDING_METHODS,
        institution: ReferenceData::INSTITUTIONS,
        itt_aim: ReferenceData::ITT_AIMS,
        nationality: ReferenceData::NATIONALITIES,
        itt_qualification_aim: ReferenceData::ITT_QUALIFICATION_AIMS,
        sex: ReferenceData::SEXES,
        study_mode: ReferenceData::STUDY_MODES,
        training_route: ReferenceData::TRAINING_ROUTES,
        training_initiative: ReferenceData::TRAINING_INITIATIVES,
      )
    end
  end

  describe "::docs_payload" do
    let(:payload) { described_class.docs_payload }

    it "returns one entry per type in TYPES" do
      expect(payload.keys).to match_array(described_class::TYPES.keys)
    end

    it "exposes type metadata under :metadata" do
      expect(payload[:disability][:metadata]).to include(
        "name" => "disability",
        "display_name" => "Disability",
      )
    end

    it "exposes rich entries under :entries" do
      first_entry = payload[:disability][:entries].first
      expect(first_entry.keys).to contain_exactly(:hesa_code, :display_name, :start_year, :end_year)
    end
  end

  describe "::api_payload" do
    let(:payload) { described_class.api_payload }

    it "returns one entry per type in TYPES plus withdrawal reasons" do
      expect(payload.keys).to match_array(described_class.available_fields)
    end

    it "exposes public metadata without source or change_log" do
      metadata = payload.fetch(:disability).fetch(:metadata)

      expect(metadata).to include(
        "name" => "disability",
        "display_name" => "Disability",
      )
      expect(metadata).not_to have_key("source")
      expect(metadata).not_to have_key("change_log")
    end

    it "renames hesa_code to code on entries" do
      first_entry = payload.fetch(:disability).fetch(:entries).first

      expect(first_entry.keys).to contain_exactly(:code, :display_name, :start_year, :end_year)
    end

    it "includes withdrawal reasons" do
      expect(payload.fetch(:withdrawal_reasons)).to eq(Api::ReferenceData::WithdrawalReasons.payload)
    end

    context "when filtering by field" do
      it "returns the unwrapped field payload" do
        expect(described_class.api_payload(field: :sex)).to eq(payload.fetch(:sex))
      end

      it "raises KeyError for an unknown field" do
        expect { described_class.api_payload(field: :bogus) }.to raise_error(KeyError)
      end
    end
  end

  describe "as_csv" do
    it "converts data to csv" do
      expect(
        CSV.parse(described_class.find(:course_age_range).as_csv),
      ).to eq(
        CSV.parse(file_content("reference_data/v2026_1/course_age_range.csv")),
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

      it "renders one row per hesa code with the locale label" do
        rows_for_0115 = rows.select { |r| r["Code"] == "0115" }
        rows_for_0204 = rows.select { |r| r["Code"] == "0204" }
        expect(rows_for_0115.size).to eq(1)
        expect(rows_for_0204.size).to eq(1)
        expect(rows_for_0115.first["Label"]).to eq("City, University of London")
        expect(rows_for_0204.first["Label"]).to eq("The University of Manchester")
      end

      it "uses locale label rather than YAML display_name" do
        winchester = rows.select { |r| r["Code"] == "0021" }
        expect(winchester.map { |r| r["Label"] }).to all(eq("The University of Winchester"))
      end
    end
  end
end
