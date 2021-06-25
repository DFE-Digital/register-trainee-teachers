# frozen_string_literal: true

RSpec.shared_examples "dttp info retriever" do
  let(:request_headers) { { headers: { "Prefer" => "odata.maxpagesize=5000" } } }
  let(:http_response) { { status: 200, body: { value: [1, 2, 3], "@odata.nextLink": "https://example.com" }.to_json } }

  before do
    allow(Dttp::AccessToken).to receive(:fetch)
    stub_request(:get, "#{Settings.dttp.api_base_url}#{expected_path}").to_return(http_response)
  end

  it "requests dttp info matching query parameters" do
    expect(Dttp::Client).to receive(:get).with(expected_path, request_headers).and_call_original
    subject
  end

  it "returns a hash containing expected items" do
    expect(subject).to eq({ items: [1, 2, 3], meta: { next_page_url: "https://example.com" } })
  end

  it_behaves_like "an http error handler"
end
