# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveUsers do
    describe "#call" do
      let(:options) { { headers: RetrieveUsers::HEADERS } }
      let(:path) { RetrieveUsers::DEFAULT_PATH }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
      end

      context "when code 200" do
        let(:status) { 200 }
        let(:body) { { value: [{ "first_name" => "Jon" }], "@odata.nextLink" => "some_path" } }
        let(:dttp_response) { double(code: status, body: body.to_json) }

        before do
          allow(Client).to receive(:get).with(path, options).and_return(dttp_response)
        end

        it "returns parsed json content" do
          expected_hash = {
            items: body[:value],
            meta: {
              next_page_url: body["@odata.nextLink"],
            },
          }

          expect(described_class.call).to eq(expected_hash)
        end
      end

      context "HTTP error" do
        let(:status) { 400 }
        let(:body) { "error" }
        let(:headers) { { foo: "bar" } }
        let(:dttp_response) { double(code: status, body: body, headers: headers) }

        it "raises a HttpError error with the response body as the message" do
          expect(Client).to receive(:get).with(path, options).and_return(dttp_response)
          expect {
            described_class.call
          }.to raise_error(Dttp::RetrieveUsers::Error, "status: #{status}, body: #{body}, headers: #{headers}")
        end
      end
    end
  end
end
