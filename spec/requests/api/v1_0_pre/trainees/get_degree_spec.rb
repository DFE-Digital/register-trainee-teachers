# frozen_string_literal: true

require "rails_helper"

describe "`GET /trainees/:trainee_slug/degrees/:slug` endpoint" do
  context "with a valid authentication token" do
    let(:provider) { trainee.provider }
    let(:token) { AuthenticationToken.create_with_random_token(provider: provider, name: "test token", created_by: provider.users.first) }
    let(:trainee_slug) { trainee.slug }
    let(:slug) { trainee.degrees.last.slug }
    let(:trainee) { create(:trainee, :with_degree) }

    context "with a valid trainee that has a degree" do
      it "returns status code 200 with a valid JSON response" do
        get "/api/v1.0-pre//trainees/#{trainee_slug}/degrees/#{slug}", headers: { Authorization: token }
        expect(response).to have_http_status(:ok)
      end
    end

    context "non existant degree" do
      let(:slug) { "non-existant" }

      it "returns status code 404 with a valid JSON response" do
        get "/api/v1.0-pre//trainees/#{trainee_slug}/degrees/#{slug}", headers: { Authorization: token }

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Degree(s) not found" })
      end
    end
  end
end
