# frozen_string_literal: true

require "rails_helper"

describe "info endpoint" do
  context "when the feature flag is off", feature_register_api: false do
    it "returns status 404" do
      get "/api/v0.1/info", headers: { Authorization: "Bearer bat" }
      expect(response).to have_http_status(:not_found)
    end
  end

  context "without a valid authentication token" do
    it "returns status 401" do
      get "/api/v0.1/info", headers: { Authorization: "Bearer bob" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with a valid authentication token and the feature flag on" do
    it "returns status 200 with a valid JSON response" do
      get "/api/v0.1/info", headers: { Authorization: "Bearer bat" }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["status"]).to eq("ok")
    end
  end
end
