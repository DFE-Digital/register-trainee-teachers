# frozen_string_literal: true

require "rails_helper"

describe "`GET /info` endpoint" do
  let(:auth_token) { create(:authentication_token) }
  let(:token) { auth_token.token }

  before do
    get "/api/#{version}/info", headers: { Authorization: token }
  end

  context "using version v2027.0" do
    let(:version) { "v2027.0" }

    it_behaves_like "a register API endpoint", "/api/v2027.0/info"

    it "shows the requested version" do
      expect(response.parsed_body).to eq({ "status" => "ok", "version" => { "latest" => "v2026.1", "requested" => "v2027.0" } })
    end
  end
end
