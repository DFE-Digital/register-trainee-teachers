# frozen_string_literal: true

require "rails_helper"

describe "DELETE /trainees/:trainee_slug/placement/:slug` endpoint" do
  context "with a valid authentication token" do
    let(:token) { "trainee_token" }
    let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
    let!(:provider) { auth_token.provider }

    context "non existant trainee" do
      let(:trainee_slug) { "non-existant" }
      let(:slug) { "non-existant" }

      it "returns status 404 with a valid JSON response" do
        api_delete(0.1, "/trainees/#{trainee_slug}/placements/#{slug}", token:)

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Trainee(s) not found" })
      end
    end

    context "non existant placement" do
      let(:trainee) { create(:trainee, provider:) }
      let(:trainee_slug) { trainee.slug }
      let(:slug) { "non-existant" }

      it "returns status 404 with a valid JSON response" do
        api_delete(0.1, "/trainees/#{trainee_slug}/placements/#{slug}", token:)

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Placement(s) not found" })
      end
    end

    context "with a deleteable a placements" do
      let(:trainee) { create(:trainee, :with_placements, provider:) }
      let(:trainee_slug) { trainee.slug }
      let(:slug) { trainee.placements.last.slug }

      it "returns status 200 with a valid JSON response" do
        api_delete(0.1, "/trainees/#{trainee_slug}/placements/#{slug}", token:)
        expect(response).to have_http_status(:ok)

        expect(response.parsed_body.dig(:data, :slug)).to eql(trainee_slug)
      end

      it "removes the specified placement" do
        expect {
          api_delete(0.1, "/trainees/#{trainee_slug}/placements/#{slug}", token:)
        } .to change { trainee.reload.placements.count }.from(2).to(1)
        .and change { trainee.reload.placements.exists?(slug:) }.from(true).to(false)
      end
    end
  end
end
