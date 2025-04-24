# frozen_string_literal: true

require "rails_helper"

describe "`GET /trainees/:trainee_slug/placements/:slug` endpoint" do
  context "with a valid authentication token" do
    let(:provider) { trainee.provider }
    let(:token) { AuthenticationToken.create_with_random_token(provider: provider, name: "test token", created_by: provider.users.first).token }
    let(:trainee_slug) { trainee.slug }
    let(:slug) { trainee.placements.last.slug }
    let(:trainee) { create(:trainee, :with_placements) }

    context "with a valid trainee that has placements" do
      it "returns status code 200 with a valid JSON response" do
        get "/api/v1.0-rc/trainees/#{trainee_slug}/placements/#{slug}", headers: { Authorization: token }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig(:data, :placement_id)).to eql(slug)
      end
    end

    context "non existant placement" do
      let(:slug) { "non-existant" }

      it "returns status code 404 with a valid JSON response" do
        get "/api/v1.0-rc/trainees/#{trainee_slug}/placements/#{slug}", headers: { Authorization: token }

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Placement(s) not found" })
      end
    end
  end
end
