# frozen_string_literal: true

require "rails_helper"

describe "`GET /trainees/:trainee_slug/placements` endpoint" do
  context "with a valid authentication token" do
    let(:provider) { trainee.provider }
    let(:token) { create(:authentication_token, provider:).token }
    let(:trainee_slug) { trainee.slug }
    let(:placements_slugs) { trainee.placements.map(&:slug) }

    context "with a valid trainee that has placements" do
      let(:trainee) { create(:trainee, :with_placements) }

      it "returns status code 200 with a valid JSON response" do
        get "/api/v2025.0/trainees/#{trainee_slug}/placements", headers: { Authorization: token }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body[:data]&.map { |x| x["placement_id"] }).to match_array(placements_slugs)
      end
    end

    context "with a valid trainee that doesn't have placements" do
      let(:trainee) { create(:trainee) }

      it "returns status code 200 with a valid JSON response" do
        get "/api/v2025.0/trainees/#{trainee_slug}/placements", headers: { Authorization: token }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"]).to be_empty
      end
    end
  end
end
