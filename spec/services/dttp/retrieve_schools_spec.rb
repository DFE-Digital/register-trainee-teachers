# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveSchools do
    let(:request_uri) { nil }
    let(:request_headers) { { headers: { "Prefer" => "odata.maxpagesize=5000" } } }
    let(:http_response) { { status: 200, body: { value: [1, 2, 3], '@odata.nextLink': "https://example.com" }.to_json } }

    subject { described_class.call(request_uri: request_uri) }

    before do
      allow(AccessToken).to receive(:fetch).and_return("token")
      stub_request(:get, "#{Settings.dttp.api_base_url}#{expected_path}").to_return(http_response)
    end

    let(:expected_path) do
      "/accounts?%24filter=dfe_provider+eq+false&%24select=name%2Cdfe_urn%2Caccountid"
    end

    it "requests schools" do
      expect(Client).to receive(:get).with(expected_path, request_headers).and_call_original
      subject
    end

    it "returns a hash containing expected items" do
      expect(subject).to eq({ items: [1, 2, 3], meta: { next_page_url: "https://example.com" } })
    end

    it_behaves_like "an http error handler"
  end
end
