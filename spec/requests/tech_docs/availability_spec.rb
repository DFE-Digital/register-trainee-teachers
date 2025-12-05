# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tech docs availability" do
  describe "/api-docs" do
    context "when allowed_versions excludes v2026.0" do
      before do
        allow(Settings.api).to receive(:allowed_versions).and_return(%w[v2025.0-rc v2025.0])
      end

      it "returns 200 for v2025.0" do
        get "/api-docs/v2025.0/"

        expect(response).to have_http_status(:success)
      end

      it "returns 404 for v2026.0" do
        get "/api-docs/v2026.0/"

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when allowed_versions includes v2026.0" do
      before do
        allow(Settings.api).to receive(:allowed_versions).and_return(%w[v2025.0-rc v2025.0 v2026.0])
      end

      %w[v2025.0 v2026.0].each do |version|
        it "returns 200 for #{version}" do
          get "/api-docs/#{version}/"

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe "/reference-data" do
    context "when allowed_versions excludes v2026.0" do
      before do
        allow(Settings.api).to receive(:allowed_versions).and_return(%w[v2025.0-rc v2025.0])
      end

      it "returns 200 for v2025.0" do
        get "/reference-data/v2025.0/"

        expect(response).to have_http_status(:success)
      end

      it "returns 404 for v2026.0" do
        get "/reference-data/v2026.0/"

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when allowed_versions includes v2026.0" do
      before do
        allow(Settings.api).to receive(:allowed_versions).and_return(%w[v2025.0-rc v2025.0 v2026.0])
      end

      %w[v2025.0 v2026.0].each do |version|
        it "returns 200 for #{version}" do
          get "/reference-data/#{version}/"

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
