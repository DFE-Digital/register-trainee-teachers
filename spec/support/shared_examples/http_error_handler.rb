# frozen_string_literal: true

RSpec.shared_examples "an http error handler" do
  let(:status) { 400 }
  let(:body) { "error" }
  let(:headers) { { "foo" => %w[bar] } }
  let(:http_response) { { status: status, body: body, headers: headers } }
  let(:expected_error) { described_class.module_parent::Client::HttpError }

  it "raises an error with the response body as the message" do
    expect {
      subject
    }.to raise_error(expected_error, "status: #{status}, body: #{body}, headers: #{headers}")
  end
end
