# frozen_string_literal: true

require "rails_helper"

describe "`GET /reference-data` endpoint" do
  context "using version v2027.0", openapi: false do
    before do
      get "/api/v2027.0/reference-data"
    end

    it "returns 404" do
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq(
        "errors" => [{ "error" => "NotFound", "message" => "Reference data is not available for version 'v2027.0'" }],
      )
    end
  end
end
