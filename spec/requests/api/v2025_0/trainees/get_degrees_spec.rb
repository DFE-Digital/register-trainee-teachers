# frozen_string_literal: true

require "rails_helper"

describe "`GET /trainees/:trainee_id/degrees` endpoint" do
  context "with a valid authentication token and the feature flag on" do
    let(:provider) { trainee.provider }
    let(:auth_token) do
      create(
        :authentication_token,
        provider:
      )
    end
    let(:token) { auth_token.token }

    context "with a valid trainee that has a degree" do
      let(:trainee) { create(:trainee, :with_degree) }

      it "returns status code 200 with a valid JSON response" do
        get(
          "/api/v2025.0/trainees/#{trainee.slug}/degrees",
          headers: { Authorization: "Bearer #{token}" },
        )
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"]).to be_present
      end
    end

    context "with a valid trainee that doesn't have a degree" do
      let(:trainee) { create(:trainee) }

      it "returns status code 200 with a valid JSON response" do
        get(
          "/api/v2025.0/trainees/#{trainee.slug}/degrees",
          headers: { Authorization: "Bearer #{token}" },
        )
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"]).to eq([])
      end
    end
  end
end
