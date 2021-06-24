# frozen_string_literal: true

RSpec.shared_examples "dttp info fetcher" do |dttp_wrapper|
  let(:dttp_id) { SecureRandom.uuid }
  let(:request_url) { "#{Settings.dttp.api_base_url}#{path}" }

  before do
    allow(Dttp::AccessToken).to receive(:fetch)
    stub_request(:get, request_url).to_return(http_response)
  end

  subject { described_class.call(dttp_id: dttp_id) }

  context "filtered params" do
    let(:parsed_response) do
      {
        "name" => "Myimaginary Dttp info",
        "modifiedon" => "2019-09-12T13:09:52Z",
      }
    end
    let(:http_response) { { status: 200, body: parsed_response.to_json } }

    it "returns a parsed response" do
      expect(subject).to be_a(dttp_wrapper)
    end
  end

  it_behaves_like "an http error handler" do
    let(:expected_error) { Dttp::Client::HttpError }
  end
end
