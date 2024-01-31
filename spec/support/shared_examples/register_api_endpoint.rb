# spec/support/shared_examples/register_api_endpoint_examples.rb

RSpec.shared_examples "a register API endpoint" do |url|
  context "when the register_api feature flag is off", feature_register_api: false do
    before do
      get url, headers: { Authorization: "Bearer bat" }
    end

    it "returns status code 404" do
      expect(response).to have_http_status(404)
    end
  end

  context "when the register_api feature flag is on", feature_register_api: true do
    before do
      get url, headers: { Authorization: "Bearer bat" }
    end

    it "returns status code 200" do
      expect(response).to have_http_status(200)
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
