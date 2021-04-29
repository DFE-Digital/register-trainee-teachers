# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveProviders do
    let(:request_uri) { nil }
    let(:request_headers) { { headers: { "Prefer" => "odata.maxpagesize=5000" } } }
    let(:dttp_response) { double(code: 200, body: { value: [1, 2, 3], '@odata.nextLink': "https://example.com" }.to_json) }

    subject { described_class.call(request_uri: request_uri) }

    before do
      allow(AccessToken).to receive(:fetch).and_return("token")
      allow(Client).to receive(:get).with(String, request_headers).and_return(dttp_response)
    end

    let(:expected_path) do
      "/accounts?%24filter=dfe_provider+eq+true+and+%28_dfe_institutiontypeid_value+eq+b5ec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+b7ec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+b9ec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+bbec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+bdec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+bfec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+c1ec33aa-216d-e711-80d2-005056ac45bb%29+and+statecode+eq+0+and+statuscode+eq+1&%24select=name%2Cdfe_ukprn%2Caccountid"
    end

    it "requests active organisations matching the institution type codeset" do
      expect(Client).to receive(:get).with(expected_path, request_headers).and_return(dttp_response)
      subject
    end

    it "returns a hash containing expected items" do
      expect(subject).to eq({ items: [1, 2, 3], meta: { next_page_url: "https://example.com" } })
    end

    context "HTTP error" do
      let(:status) { 400 }
      let(:body) { "error" }
      let(:headers) { { foo: "bar" } }
      let(:dttp_response) { double(code: status, body: body, headers: headers) }

      it "raises an Error with the response body as the message" do
        expect(Client).to receive(:get).with(String, request_headers).and_return(dttp_response)
        expect {
          subject
        }.to raise_error(described_class::Error, "status: #{status}, body: #{body}, headers: #{headers}")
      end
    end
  end
end
