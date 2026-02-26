# frozen_string_literal: true

require "rails_helper"

describe "`POST /trainees/:trainee_id/degrees` endpoint" do
  include ErrorMessageHelper

  context "with a valid authentication token and the feature flag on" do
    let(:provider) { trainee.provider }
    let(:token) { create(:authentication_token, provider:).token }
    let(:trainee) { create(:trainee) }
    let(:degrees_attributes) do
      {
        grade: "02",
        subject: "100425",
        institution: "1166",
        uk_degree: "014",
        graduation_year: "2015-01-01",
        country: "XF",
      }
    end

    context "with a valid trainee and uk degree" do
      it "creates a new degree and returns a 201 (created) status" do
        post(
          "/api/v2026.1/trainees/#{trainee.slug}/degrees",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: {
            data: degrees_attributes,
          }.to_json,
        )

        expect(response).to have_http_status(:created)

        degree_attributes = response.parsed_body["data"]

        expect(degree_attributes["grade"]).to eq("02")
        expect(degree_attributes["subject"]).to eq("100425")
        expect(degree_attributes["institution"]).to eq("1166")
        expect(degree_attributes["uk_degree"]).to eq("014")
        expect(degree_attributes["graduation_year"]).to eq(2015)
        expect(degree_attributes["country"]).to be_nil
        expect(degree_attributes["locale_code"]).to be_nil

        expect(trainee.reload.progress[:degrees]).to be(true)
        expect(trainee.degrees.count).to eq(1)

        degree = trainee.degrees.last

        expect(degree.grade).to eq("Upper second-class honours (2:1)")
        expect(degree.grade_uuid).to eq("e2fe18d4-8655-47cf-ab1a-8c3e0b0f078f")
        expect(degree.subject).to eq("Physics")
        expect(degree.subject_uuid).to eq("918170f0-5dce-e911-a985-000d3ab79618")
        expect(degree.institution).to eq("Blackburn College")
        expect(degree.institution_uuid).to eq("c63d87ce-7c3d-4e5a-93e2-337b71426d8f")
        expect(degree.uk_degree).to eq("Bachelor of Arts (Hons) with intercalated PGCE")
        expect(degree.uk_degree_uuid).to eq("0caa1ea5-868a-47a4-9b26-4b7470528b67")

        expect(degree.graduation_year).to eq(2015)
        expect(degree.country).to be_nil
        expect(degree.locale_code).to eq("uk")
      end
    end

    context "with a valid trainee and non uk degree" do
      let(:degrees_attributes) do
        {
          grade: "02",
          subject: "100425",
          non_uk_degree: "083",
          graduation_year: "2015-01-01",
          country: "GL",
        }
      end

      it "creates a new degree and returns a 201 (created) status" do
        post(
          "/api/v2026.1/trainees/#{trainee.slug}/degrees",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: {
            data: degrees_attributes,
          }.to_json,
        )

        expect(response).to have_http_status(:created)

        degree_attributes = response.parsed_body["data"]

        expect(degree_attributes["grade"]).to eq("02")
        expect(degree_attributes["subject"]).to eq("100425")
        expect(degree_attributes["institution"]).to be_nil
        expect(degree_attributes["uk_degree"]).to be_nil
        expect(degree_attributes["graduation_year"]).to eq(2015)
        expect(degree_attributes["country"]).to eq("GL")
        expect(degree_attributes["locale_code"]).to be_nil

        expect(trainee.reload.progress[:degrees]).to be(true)
        expect(trainee.degrees.count).to eq(1)

        degree = trainee.degrees.last

        expect(degree.grade).to eq("Upper second-class honours (2:1)")
        expect(degree.grade_uuid).to eq("e2fe18d4-8655-47cf-ab1a-8c3e0b0f078f")
        expect(degree.subject).to eq("Physics")
        expect(degree.subject_uuid).to eq("918170f0-5dce-e911-a985-000d3ab79618")
        expect(degree.institution).to be_nil
        expect(degree.institution_uuid).to be_nil
        expect(degree.uk_degree).to be_nil
        expect(degree.uk_degree_uuid).to be_nil

        expect(degree.graduation_year).to eq(2015)
        expect(degree.country).to eq("Greenland")
        expect(degree.locale_code).to eq("non_uk")
      end
    end

    context "with duplicate degree" do
      let(:trainee) { create(:trainee, :with_degree) }
      let(:degrees_attributes) do
        attributes = Api::V20261::DegreeSerializer.new(trainee.degrees.first).as_hash.symbolize_keys.slice(
          :country, :grade, :grade_uuid, :subject, :subject_uuid, :institution, :institution_uuid, :uk_degree, :uk_degree_uuid, :graduation_year
        )
        attributes[:graduation_year] = Date.new(attributes[:graduation_year]).to_s
        attributes
      end

      it "returns a 409 (conflict) status" do
        post(
          "/api/v2026.1/trainees/#{trainee.slug}/degrees",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: {
            data: degrees_attributes,
          }.to_json,
        )
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body["errors"].first).to match(
          { error: "Conflict",
            message: "This is a duplicate degree" },
        )
        expect(response.parsed_body["data"]).to contain_exactly(
          JSON.parse(Api::V20261::DegreeSerializer.new(trainee.degrees.first).as_hash.to_json),
        )
        expect(trainee.reload.degrees.count).to eq(1)
      end
    end

    context "with an invalid trainee" do
      let(:trainee_for_another_provider) { create(:trainee) }

      it "does not create a new degree and returns a 404 status (not_found) status" do
        post(
          "/api/v2026.1/trainees/#{trainee_for_another_provider.slug}/degrees",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: {
            data: degrees_attributes,
          }.to_json,
        )
        expect(response).to have_http_status(:not_found)
        expect(trainee.reload.degrees.count).to eq(0)
      end
    end

    context "with invalid degree attributes" do
      let(:degrees_attributes) do
        {
          grade: "First",
          subject: "Practical Magic",
          graduation_year: (Time.zone.now.year + 2).to_s,
        }
      end

      before do
        post(
          "/api/v2026.1/trainees/#{trainee.slug}/degrees",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: {
            data:,
          }.to_json,
        )
      end

      context "with a uk_degree" do
        let(:data) do
          degrees_attributes.merge(
            uk_degree: "Bachelor of Arts",
            institution: "University of Oxford",
            country: "France",
          )
        end

        it "does not create a new degree and returns a 422 status (unprocessable_entity) status" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to contain_exactly(
            { "error" => "UnprocessableEntity", "message" => "graduation_year must be in the past, for example 2014" },
            { "error" => "UnprocessableEntity", "message" => "graduation_year is invalid" },
            { "error" => "UnprocessableEntity", "message" => "subject must be entered if specifying a previous UK degree or non-UK degree" },
            { "error" => "UnprocessableEntity", "message" => "uk_degree has invalid reference data value of 'Bachelor of Arts'. Example values include #{format_reference_data_list(DfEReference::DegreesQuery::TYPES.all.map(&:hesa_itt_code).compact.uniq)}..." },
            { "error" => "UnprocessableEntity", "message" => "grade must be entered if specifying a previous UK degree or non-UK degree" },
          )
          expect(trainee.reload.degrees.count).to eq(0)
        end
      end

      context "with a non_uk_degree" do
        let(:data) do
          degrees_attributes.merge(
            country: "France",
            non_uk_degree: "Bachelor of Arts",
          )
        end

        it "does not create a new degree and returns a 422 status (unprocessable_entity) status" do
          expect(response).to have_http_status(:unprocessable_entity)

          expect(response.parsed_body[:errors]).to contain_exactly(
            { "error" => "UnprocessableEntity", "message" => "graduation_year must be in the past, for example 2014" },
            { "error" => "UnprocessableEntity", "message" => "graduation_year is invalid" },
            { "error" => "UnprocessableEntity", "message" => "subject must be entered if specifying a previous UK degree or non-UK degree" },
            { "error" => "UnprocessableEntity", "message" => "non_uk_degree has invalid reference data value of 'Bachelor of Arts'. Example values include #{format_reference_data_list(DfEReference::DegreesQuery::TYPES.all.map(&:hesa_itt_code).compact.uniq)}..." },
            { "error" => "UnprocessableEntity", "message" => "country has invalid reference data value of 'France'. Example values include #{format_reference_data_list(Hesa::CodeSets::Countries::MAPPING.keys)}..." },
          )
          expect(trainee.reload.degrees.count).to eq(0)
        end
      end
    end
  end
end
