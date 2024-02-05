# frozen_string_literal: true

require "rails_helper"

describe "info endpoint" do
  it_behaves_like "a register API endpoint", "/api/v0.1/info"

  context "with a valid authentication token and the feature flag on" do
    it "returns status 200 with a valid JSON response" do
      get "/api/v0.1/info", headers: { Authorization: "Bearer bat" }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["status"]).to eq("ok")
    end
  end
end
