# frozen_string_literal: true

require "rails_helper"

describe "`GET /reference-data` endpoint" do
  it_behaves_like "a reference data endpoint", "v2026.1"

  context "using version v2026.1", openapi: false do
    before do
      get "/api/v2026.1/reference-data"
    end

    it "includes v2026.1 field names" do
      expect(response.parsed_body.keys).to include("course_subject", "degree_type", "disability")
    end

    it "matches api_payload for a sample field" do
      expect(response.parsed_body.fetch("sex")).to eq(
        Hesa::ReferenceData::V20261.api_payload(field: :sex).deep_stringify_keys,
      )
    end
  end
end
