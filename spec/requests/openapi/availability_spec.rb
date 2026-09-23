# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OpenAPI yaml availability" do
  describe "/openapi" do
    context "when allowed_versions excludes v2027.0" do
      before do
        allow(Settings.api).to receive(:allowed_versions).and_return(%w[v2026.1])
      end

      it "returns 200 for v2026.1" do
        get "/openapi/v2026.1.yaml"

        expect(response).to have_http_status(:ok)
      end

      it "returns 404 for v2027.0" do
        get "/openapi/v2027.0.yaml"

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when allowed_versions includes v2027.0" do
      before do
        allow(Settings.api).to receive(:allowed_versions).and_return(%w[v2026.1 v2027.0])
      end

      it "returns 200 for v2026.1" do
        get "/openapi/v2026.1.yaml"

        expect(response).to have_http_status(:ok)
      end

      it "returns 200 for v2027.0" do
        get "/openapi/v2027.0.yaml"

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
