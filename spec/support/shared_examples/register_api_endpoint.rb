# frozen_string_literal: true

RSpec.shared_examples "a register API endpoint" do |url, api_token|
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

    it "returns status 200" do
      expect(response).to have_http_status(:ok)
    end

    it "increments the requests_total counter" do
      expect { get url, headers: { Authorization: token } }
        .to change { Yabeda.register_api.requests_total.values.values.sum }
        .by(1)
    end

    it "measures the request_duration histogram" do
      expect(Yabeda.register_api.request_duration.values.values.sum).to be > 0
    end

    context "when the register_api feature flag is off", feature_register_api: false do
      it "returns status code 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with an invalid version" do
      it "returns status 404" do
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

    it "returns status 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
