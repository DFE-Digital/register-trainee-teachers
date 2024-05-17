# frozen_string_literal: true

require "rails_helper"

describe "`GET /info` endpoint" do
  let(:token) { "info_token" }
  let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }

  before do
    get "/api/#{version}/info", headers: { Authorization: token }
  end

  context "using version v1.0" do
    let(:version) { "v1.0" }

    it_behaves_like "a register API endpoint", "/api/v1.0/info", "info_token"

    it "shows the requested version" do
      expect(response.parsed_body).to eq({ "status" => "ok", "version" => { "next" => "v1.0", "requested" => "v1.0" } })
    end
  end
end
