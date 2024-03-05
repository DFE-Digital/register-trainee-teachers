# frozen_string_literal: true

require "rails_helper"

describe "`PUT /trainees/:trainee_slug/degrees/:slug` endpoint" do
  context "with a valid authentication token and the feature flag on" do
    let(:accountancy_subject_uuid) { "917f70f0-5dce-e911-a985-000d3ab79618" }
    let(:accounting_subject_uuid) { "937f70f0-5dce-e911-a985-000d3ab79618" }

    let(:provider) { trainee.provider }
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }
    let(:auth_token) do
      create(
        :authentication_token,
        hashed_token: AuthenticationToken.hash_token(token),
      )
    end
    let(:trainee) { create(:trainee) }
    let!(:degree) do
      create(
        :degree,
        :uk_degree_with_details,
        trainee: trainee,
        subject_uuid: accountancy_subject_uuid,
      )
    end
    let!(:original_subject) { degree.subject }
    let(:new_subject) { "Accounting" }

    context "with a valid trainee and degree" do
      it "updates a new degree and returns a 200 status (ok)" do
        put(
          "/api/v0.1/trainees/#{trainee.slug}/degrees/#{degree.slug}",
          headers: { Authorization: "Bearer #{token}" },
          params: {
            data: { subject: new_subject },
          },
        )
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"]).to be_present
        expect(trainee.reload.degrees.first.subject).to eq(new_subject)
      end
    end

    context "with an invalid trainee" do
      let(:trainee_for_another_provider) { create(:trainee) }

      it "does not update the degree and returns a 404 status (not_found)" do
        put(
          "/api/v0.1/trainees/#{trainee_for_another_provider.slug}/degrees/#{degree.slug}",
          headers: { Authorization: "Bearer #{token}" },
          params: {
            data: { subject: new_subject },
          },
        )
        expect(response).to have_http_status(:not_found)
        expect(trainee.reload.degrees.count).to eq(1)
        expect(trainee.reload.degrees.first.subject).to eq(original_subject)
      end
    end

    context "with an invalid degree" do
      it "does not update the degree and returns a 422 status (unprocessable_entity)" do
        put(
          "/api/v0.1/trainees/#{trainee.slug}/degrees/#{degree.slug}",
          headers: { Authorization: "Bearer #{token}" },
          params: {
            data: { subject: "Practical Magic" },
          },
        )
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]&.count).to eq(1)
        expect(trainee.reload.degrees.first.subject).to eq(original_subject)
      end
    end

    context "with an invalid request structure" do
      it "does not update the degree and returns a 422 status (unprocessable_entity)" do
        put(
          "/api/v0.1/trainees/#{trainee.slug}/degrees/#{degree.slug}",
          headers: { Authorization: "Bearer #{token}" },
          params: {
            foo: { subject: "new_subject" },
          },
        )
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to eq(["Request could not be parsed"])
        expect(trainee.reload.degrees.first.subject).to eq(original_subject)
      end
    end
  end
end
