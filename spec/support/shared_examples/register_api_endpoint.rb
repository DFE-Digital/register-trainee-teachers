# frozen_string_literal: true

RSpec.shared_examples "a register API endpoint", openapi: false do |url, api_token, openapi: false|
  context "with a valid authentication token" do
    let(:token) do
      if api_token.blank?
        create(:authentication_token, hashed_token: AuthenticationToken.hash_token("valid_token"))
      end
      api_token || "valid_token"
    end

    before do
      get url, headers: { Authorization: token }
    end

    it "returns status 200", openapi: do
      expect(response).to have_http_status(:ok)
    end

    context "when the register_api feature flag is off", feature_register_api: false do
      it "returns status code 404", openapi: do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with an invalid version" do
      it "returns status 404", openapi: do
        invalid_version_url = url.sub(/v[.0-9]+/, "v0.0")
        get invalid_version_url, headers: { Authorization: token }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context "without a valid authentication token" do
    before do
      get url, headers: { Authorization: "Bearer bob" }
    end

    it "returns status 401", openapi: do
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
