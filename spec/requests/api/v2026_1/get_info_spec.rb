# frozen_string_literal: true

require "rails_helper"

describe "`GET /info` endpoint" do
  let(:auth_token) { create(:authentication_token) }
  let(:token) { auth_token.token }

  before do
    get "/api/#{version}/info", headers: { Authorization: token }
  end

  context "using version v2026.1" do
    let(:version) { "v2026.1" }

    it_behaves_like "a register API endpoint", "/api/v2026.1/info"

    it "shows the requested version" do
      expect(response.parsed_body).to eq({ "status" => "ok", "version" => { "latest" => "v2025.0", "requested" => "v2026.1" } })
    end
  end
end
