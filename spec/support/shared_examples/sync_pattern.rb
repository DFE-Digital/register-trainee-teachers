# frozen_string_literal: true

RSpec.shared_examples "dttp info retriever" do |_parameter|
  let(:request_headers) { { headers: { "Prefer" => "odata.maxpagesize=5000" } } }
  let(:dttp_response) { double(code: 200, body: { value: [1, 2, 3], '@odata.nextLink': "https://example.com" }.to_json) }

  before do
    allow(Dttp::Client).to receive(:get).with(expected_path, request_headers).and_return(dttp_response)
  end

  it "requests dttp info matching query parameters" do
    expect(Dttp::Client).to receive(:get).with(expected_path, request_headers).and_return(dttp_response)
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
      expect(Dttp::Client).to receive(:get).with(expected_path, request_headers).and_return(dttp_response)
      expect {
        subject
      }.to raise_error(Dttp::SyncPattern::Error, "status: #{status}, body: #{body}, headers: #{headers}")
    end
  end
end
