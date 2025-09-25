# frozen_string_literal: true

require "rails_helper"

describe "`GET /api/v2025.0/trainees/:id` endpoint" do
  let!(:auth_token) { create(:authentication_token) }
  let!(:token) { auth_token.token }
  let!(:trainee) { create(:trainee, :with_hesa_trainee_detail, slug: "12345", provider: auth_token.provider) }

  it_behaves_like "a register API endpoint", "/api/v2025.0/trainees/12345"

  context "when the trainee exists" do
    before do
      get(
        "/api/v2025.0/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
      )
    end

    it "returns the trainee" do
      parsed_trainee = JSON.parse(Api::GetVersionedItem.for_serializer(model: :trainee, version: "v2025.0").new(trainee).as_hash.to_json)
      expect(response.parsed_body).to eq(parsed_trainee)
    end

    it "returns status 200" do
      expect(response).to have_http_status(:ok)
    end
  end

  context "when the trainee does not exist" do
    before do
      get(
        "/api/v2025.0/trainees/nonexistent",
        headers: { Authorization: "Bearer #{token}" },
      )
    end

    it "returns status 404" do
      expect(response).to have_http_status(:not_found)
    end

    it "returns a not found message" do
      expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Trainee(s) not found" })
    end
  end
end
