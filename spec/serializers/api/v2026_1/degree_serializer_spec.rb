# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20261::DegreeSerializer do
  let(:degree) { create(:degree) }
  let(:json) { described_class.new(degree).as_hash }

  describe "serialization" do
    let(:fields) do
      %w[
        degree_id
        uk_degree
        non_uk_degree
        created_at
        updated_at
        subject
        institution
        graduation_year
        grade
        country
        other_grade
        institution_uuid
        uk_degree_uuid
        subject_uuid
        grade_uuid
      ]
    end

    it "matches the fields" do
      expect(json.keys).to match_array(fields)
    end
  end

  describe "HESA codes" do
    context "with a UK degree" do
      let(:degree) do
        create(:degree, :uk_degree_type,
               subject: "Computing",
               institution: "Brunel University London",
               grade: "First-class honours",
               uk_degree: "Bachelor of Arts")
      end

      it "serializes each reference value as its HESA code" do
        expect(json[:subject]).to eq("100367")
        expect(json[:institution]).to eq("0113")
        expect(json[:grade]).to eq("01")
        expect(json[:uk_degree]).to eq("051")
      end
    end

    context "with a non-UK degree" do
      let(:degree) do
        create(:degree, :non_uk_degree_type, country: "Kosovo", subject: "Computing")
      end

      it "serializes the country as its HESA code" do
        expect(json[:country]).to eq("QO")
      end
    end

    context "with a superseded subject label still stored against the degree" do
      let(:degree) { create(:degree, :uk_degree_type, subject: "Computing and information technology") }

      it "still serializes the subject HESA code" do
        expect(json[:subject]).to eq("100367")
      end
    end
  end
end
