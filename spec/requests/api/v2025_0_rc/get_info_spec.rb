# frozen_string_literal: true

require "rails_helper"

describe "`GET /info` endpoint" do
  let(:auth_token) { create(:authentication_token) }
  let(:token) { auth_token.token }

  before do
    get "/api/#{version}/info", headers: { Authorization: token }
  end

  context "using version v2025.0-rc" do
    let(:version) { "v2025.0-rc" }

    it_behaves_like "a register API endpoint", "/api/v2025.0-rc/info"

    it "shows the requested version" do
      expect(response.parsed_body).to eq({ "status" => "ok", "version" => { "latest" => "v2025.0", "requested" => "v2025.0-rc" } })
    end
  end
end
