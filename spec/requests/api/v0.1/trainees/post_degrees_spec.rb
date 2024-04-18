# frozen_string_literal: true

require "rails_helper"

describe "`POST /trainees/:trainee_id/degrees` endpoint" do
  context "with a valid authentication token and the feature flag on" do
    let(:provider) { trainee.provider }
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }
    let(:auth_token) do
      create(
        :authentication_token,
        hashed_token: AuthenticationToken.hash_token(token),
      )
    end
    let(:trainee) { create(:trainee) }
    let(:degrees_attributes) do
      {
        grade: "02",
        subject: "100425",
        institution: "0117",
        uk_degree: "083",
        graduation_year: "2015-01-01",
        country: "XF",
        locale_code: "uk",
      }
    end

    context "with a valid trainee and degree" do
      it "creates a new degree and returns a 201 (created) status" do
        post(
          "/api/v0.1/trainees/#{trainee.slug}/degrees",
          headers: { Authorization: "Bearer #{token}" },
          params: {
            data: degrees_attributes,
          },
        )

        expect(response).to have_http_status(:created)

        degree_attributes = response.parsed_body["data"]

        expect(degree_attributes["grade"]).to eq("02")
        expect(degree_attributes["subject"]).to eq("100425")
        expect(degree_attributes["institution"]).to eq("0117")
        expect(degree_attributes["uk_degree"]).to eq("083")
        expect(degree_attributes["graduation_year"]).to eq(2015)
        expect(degree_attributes["country"]).to be_nil
        expect(degree_attributes["locale_code"]).to be_nil

        expect(trainee.reload.progress[:degrees]).to be(true)
        expect(trainee.degrees.count).to eq(1)

        degree = trainee.degrees.last

        expect(degree.grade).to eq("Upper second-class honours (2:1)")
        expect(degree.subject).to eq("Physics")
        expect(degree.institution).to eq("University of East Anglia")
        expect(degree.uk_degree).to eq("Bachelor of Science")
        expect(degree.graduation_year).to eq(2015)
        expect(degree.country).to be_nil
        expect(degree.locale_code).to eq("uk")
      end
    end

    context "with duplicate degree" do
      let(:trainee) { create(:trainee, :with_degree) }
      let(:degrees_attributes) do
        attributes = DegreeSerializer::V01.new(trainee.degrees.first).as_hash.symbolize_keys.slice(
          :country, :grade, :grade_uuid, :subject, :subject_uuid, :institution, :institution_uuid, :uk_degree, :uk_degree_uuid, :graduation_year, :locale_code
        )
        attributes[:graduation_year] = Date.new(attributes[:graduation_year]).to_s
        attributes
      end

      it "returns a 409 (conflict) status" do
        post(
          "/api/v0.1/trainees/#{trainee.slug}/degrees",
          headers: { Authorization: "Bearer #{token}" },
          params: {
            data: degrees_attributes,
          },
        )
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body["errors"].first).to match(
          { error: "Conflict",
            message: "This is a duplicate degree" },
        )
        expect(trainee.reload.degrees.count).to eq(1)
      end
    end

    context "with an invalid trainee" do
      let(:trainee_for_another_provider) { create(:trainee) }

      it "does not create a new degree and returns a 404 status (not_found) status" do
        post(
          "/api/v0.1/trainees/#{trainee_for_another_provider.slug}/degrees",
          headers: { Authorization: "Bearer #{token}" },
          params: {
            data: degrees_attributes,
          },
        )
        expect(response).to have_http_status(:not_found)
        expect(trainee.reload.degrees.count).to eq(0)
      end
    end

    context "with invalid degree attributes" do
      let(:degrees_attributes) do
        {
          country: "UK",
          grade: "First",
          subject: "Practical Magic",
          institution: "University of Oxford",
          uk_degree: "Bachelor of Witchcraft & Wizardry",
          graduation_year: "01-01-2012",
          locale_code: "uk",
        }
      end

      it "does not create a new degree and returns a 422 status (unprocessable_entity) status" do
        post(
          "/api/v0.1/trainees/#{trainee.slug}/degrees",
          headers: { Authorization: "Bearer #{token}" },
          params: {
            data: degrees_attributes,
          },
        )

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]&.count).to eq(3)
        expect(trainee.reload.degrees.count).to eq(0)
      end
    end
  end
end
