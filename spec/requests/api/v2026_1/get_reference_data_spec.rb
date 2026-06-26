# frozen_string_literal: true

require "rails_helper"

describe "`GET /reference-data` endpoint" do
  it_behaves_like "a reference data endpoint", "v2026.1"

  context "using version v2025.0" do
    before do
      get "/api/v2025.0/reference-data"
    end

    it "returns status code 404" do
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq(
        "errors" => [{ "error" => "NotFound", "message" => "Reference data is not available for version 'v2025.0'" }],
      )
    end
  end

  context "using version v2026.1" do
    before do
      get "/api/v2026.1/reference-data"
    end

    it "includes v2026.1 field names" do
      expect(response.parsed_body.keys).to include("course_subject", "degree_type", "disability")
    end

    it "matches docs_payload for a sample field" do
      expect(response.parsed_body.fetch("sex")).to eq(
        Hesa::ReferenceData::V20261.docs_payload.fetch(:sex).deep_stringify_keys,
      )
    end
  end
end
