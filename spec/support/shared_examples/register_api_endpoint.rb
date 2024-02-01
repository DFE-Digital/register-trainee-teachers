# frozen_string_literal: true

# spec/support/shared_examples/register_api_endpoint_examples.rb

RSpec.shared_examples "a register API endpoint" do |url|
  context "when the register_api feature flag is off", feature_register_api: false do
    before do
      get url, headers: { Authorization: "Bearer bat" }
    end

    it "returns status code 404" do
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when the register_api feature flag is on", feature_register_api: true do
    before do
      get url, headers: { Authorization: "Bearer bat" }
    end

    it "returns status code 200" do
      expect(response).to have_http_status(:ok)
    end
  end

  context "without a valid authentication token" do
    before do
      get url, headers: { Authorization: "Bearer bob" }
    end

    it "returns status 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with an invalid version" do
    it "returns status 404" do
      invalid_version_url = url.sub(/v[.0-9]+/, 'v0.0')
      get invalid_version_url, headers: { Authorization: "Bearer bat" }
      expect(response).to have_http_status(:not_found)
    end
  end
end
