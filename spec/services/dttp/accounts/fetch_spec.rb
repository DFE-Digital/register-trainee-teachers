# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Accounts
    describe Fetch do
      describe "#call" do
        let(:dttp_id) { SecureRandom.uuid }
        let(:path) { "/accounts(#{dttp_id})" }

        before do
          allow(AccessToken).to receive(:fetch).and_return("token")
          allow(Client).to receive(:get).with(path).and_return(dttp_response)
        end

        context "filtered params" do
          let(:parsed_response) do
            {
              "name" => "Myimaginary University",
              "modifiedon" => "2019-09-12T13:09:52Z",
            }
          end
          let(:dttp_response) { double(code: 200, body: parsed_response.to_json) }

          it "returns a parsed response" do
            expect(described_class.call(dttp_id: dttp_id)).to be_a(Dttp::Account)
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
              described_class.call(dttp_id: dttp_id)
            }.to raise_error(Dttp::Accounts::Fetch::HttpError, "status: #{status}, body: #{body}, headers: #{headers}")
          end
        end
      end
    end
  end
end
