# frozen_string_literal: true

require "rails_helper"

describe "`GET /trainees/:trainee_slug/placements/:slug` endpoint" do
  context "with a valid authentication token" do
    let(:provider) { trainee.provider }
    let(:token) { create(:authentication_token, provider:).token }
    let(:trainee_slug) { trainee.slug }
    let(:slug) { trainee.placements.last.slug }
    let(:trainee) { create(:trainee, :with_placements) }

    context "with a valid trainee that has placements" do
      it "returns status code 200 with a valid JSON response" do
        get "/api/v2025.0/trainees/#{trainee_slug}/placements/#{slug}", headers: { Authorization: token }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig(:data, :placement_id)).to eql(slug)
      end
    end

    context "non existant placement" do
      let(:slug) { "non-existant" }

      it "returns status code 404 with a valid JSON response" do
        get "/api/v2025.0/trainees/#{trainee_slug}/placements/#{slug}", headers: { Authorization: token }

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Placement(s) not found" })
      end
    end
  end
end
