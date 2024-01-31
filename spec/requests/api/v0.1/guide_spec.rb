# frozen_string_literal: true

require "rails_helper"

describe "guidance endpoint" do
  context "visiting with api feature flag", feature_register_api: true do
    it "returns status 200" do
      get "/api/v0.1/guide"
      expect(response).to have_http_status(:ok)
    end
  end

  context "visiting without api feature flag", feature_register_api: false do
    it "returns status 404" do
      get "/api/v0.1/guide"
      expect(response).to have_http_status(:found)
      follow_redirect!
      expect(response).to have_http_status(:not_found)
    end
  end
end
