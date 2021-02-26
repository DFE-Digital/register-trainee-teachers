# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe AccessToken do
    describe described_class::Client do
      it "uses the microsoft base uri" do
        expect(described_class.base_uri).to eq("https://login.microsoftonline.com")
      end
    end

    describe ".fetch" do
      let(:client_id) { "client_id_from_env" }
      let(:scope) { "https://dttp-dev.crm4.dynamics.com/.default" }
      let(:client_secret) { "secret_from_env" }
      let(:tenant_id) { "tenant_id_from_env" }
      let(:path) { "/#{tenant_id}/oauth2/v2.0/token" }

      before do
        allow(Settings.dttp).to receive(:client_id).and_return(client_id)
        allow(Settings.dttp).to receive(:scope).and_return(scope)
        allow(Settings.dttp).to receive(:client_secret).and_return(client_secret)
        allow(Settings.dttp).to receive(:tenant_id).and_return(tenant_id)

        response = double(body: { access_token: "token", expires_in: 3600 }.to_json)

        allow(described_class::Client).to receive(:post).with(path, body: AccessToken::REQUEST_BODY).and_return(response)
      end

      it "returns the access token" do
        expect(described_class.fetch).to eq("token")
      end
    end
  end
end
