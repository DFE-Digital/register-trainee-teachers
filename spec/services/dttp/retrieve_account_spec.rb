# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveAccount do
    describe "#call" do
      let(:account_entity_id) { SecureRandom.uuid }
      let(:provider) { create(:provider, dttp_id: account_entity_id) }
      let(:fields) { "name" }
      let(:path) { "/accounts(#{provider.dttp_id})?$select=#{fields}" }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
        allow(Client).to receive(:get).with(path).and_return(dttp_response)
      end

      context "filtered params" do
        let(:parsed_response) do
          {
            "name" => "Myimaginary University",
          }
        end
        let(:dttp_response) { double(code: 200, body: parsed_response.to_json) }

        it "returns a parsed response" do
          expect(described_class.call(provider: provider)).to eq(parsed_response)
        end
      end

      context "HTTP error" do
        let(:status) { 400 }
        let(:body) { "error" }
        let(:headers) { { foo: "bar" } }
        let(:dttp_response) { double(code: status, body: body, headers: headers) }

        it "raises a HttpError with the response body as the message" do
          expect(Client).to receive(:get).with(path).and_return(dttp_response)
          expect {
            described_class.call(provider: provider)
          }.to raise_error(Dttp::RetrieveAccount::HttpError, "status: #{status}, body: #{body}, headers: #{headers}")
        end
      end
    end
  end
end
