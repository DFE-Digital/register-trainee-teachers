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
        country: "UK",
        grade: "First",
        subject: "Applied linguistics",
        institution: "University of Oxford",
        uk_degree: "Bachelor of Arts",
        graduation_year: "2012",
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
        expect(response.parsed_body["data"]).to be_present
        expect(trainee.reload.degrees.count).to eq(1)
      end

      it "updates the progress attribute on the trainee" do
        post(
          "/api/v0.1/trainees/#{trainee.slug}/degrees",
          headers: { Authorization: "Bearer #{token}" },
          params: {
            data: degrees_attributes,
          },
        )
        expect(trainee.reload.progress[:degrees]).to be(true)
      end
    end

    context "with duplicate degree" do
      let(:trainee) { create(:trainee, :with_degree) }
      let(:degrees_attributes) do
        trainee.degrees.first.attributes.symbolize_keys.slice(
          :country, :grade, :grade_uuid, :subject, :subject_uuid, :institution, :institution_uuid, :uk_degree, :uk_degree_uuid, :graduation_year, :locale_code
        )
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

    context "with an invalid degree" do
      let(:degrees_attributes) do
        {
          country: "UK",
          grade: "First",
          subject: "Practical Magic",
          institution: "University of Oxford",
          uk_degree: "Bachelor of Witchcraft & Wizardry",
          graduation_year: "2012",
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
        expect(response.parsed_body["errors"]&.count).to eq(2)
        expect(trainee.reload.degrees.count).to eq(0)
      end
    end
  end
end
