# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveProviders do
    let(:request_uri) { nil }
    let(:request_headers) { { headers: { "Prefer" => "odata.maxpagesize=25" } } }
    let(:dttp_response) { double(code: 200, body: { value: [1, 2, 3], '@odata.nextLink': "https://example.com" }.to_json) }

    subject { described_class.call(request_uri: request_uri) }

    before do
      allow(AccessToken).to receive(:fetch).and_return("token")
      allow(Client).to receive(:get).with(String, request_headers).and_return(dttp_response)
    end

    it "returns a hash containing expected items" do
      expect(subject).to eq({ items: [1, 2, 3], meta: { next_page_url: "https://example.com" } })
    end

    context "HTTP error" do
      let(:status) { 400 }
      let(:body) { "error" }
      let(:headers) { { foo: "bar" } }
      let(:dttp_response) { double(code: status, body: body, headers: headers) }

      it "raises a HttpError error with the response body as the message" do
        expect(Client).to receive(:get).with(String, request_headers).and_return(dttp_response)
        expect {
          subject
        }.to raise_error(described_class::HttpError, "status: #{status}, body: #{body}, headers: #{headers}")
      end
    end
  end
end
