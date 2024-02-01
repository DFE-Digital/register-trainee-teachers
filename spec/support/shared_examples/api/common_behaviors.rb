# frozen_string_literal: true

shared_examples "API: authentication and feature flags" do |version, endpoint|
  context "when the feature flag is off", feature_register_api: false do
    it "returns status 404" do
      api_get version, endpoint
      expect(response).to have_http_status(:not_found)
    end
  end

  context "without a valid authentication token" do
    it "returns status 401" do
      api_get version, endpoint, token: "bob"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with an invalid version" do
    it "returns status 404" do
      api_get 20, endpoint
      expect(response).to have_http_status(:not_found)
    end
  end
end
