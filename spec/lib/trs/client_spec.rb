# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trs::Client, type: :model do
  describe "Request" do
    it "has the correct base_uri" do
      expect(Trs::Client::Request.base_uri).to eq(Settings.trs.base_url)
    end

    it "includes the correct headers" do
      headers = Trs::Client::Request.headers
      expect(headers["Accept"]).to eq("application/json")
      expect(headers["Content-Type"]).to eq("application/json;odata.metadata=minimal")
      expect(headers["X-Api-Version"]).to eq(Settings.trs.version)
      expect(headers["Authorization"]).to eq("Bearer #{Settings.trs.api_key}")
    end
  end

  describe "handle_response" do
    let(:success_response) { double("response", code: 200, body: '{"key":"value"}', headers: {}) }
    let(:failure_response) { double("response", code: 500, body: "Internal Server Error", headers: {}) }

    it "parses the response body on success" do
      result = Trs::Client.handle_response(response: success_response, statuses: [200])
      expect(result).to eq({ "key" => "value" })
    end

    it "raises an error on failure" do
      expect {
        Trs::Client.handle_response(response: failure_response, statuses: [200])
      }.to raise_error(Trs::Client::HttpError, /status: 500/)
    end
  end

  describe "self methods" do
    let(:success_response) { double("response", code: 200, body: '{"key":"value"}', headers: {}) }
    let(:failure_response) { double("response", code: 500, body: "Internal Server Error", headers: {}) }
    let(:url) { "/test_endpoint" }
    let(:options) { { query: { param1: "value1" } } }

    before do
      allow(Trs::Client::Request).to receive(:get).with(url, options).and_return(success_response)
      allow(Trs::Client::Request).to receive(:put).with(url, options).and_return(success_response)
      allow(Trs::Client::Request).to receive(:post).with(url, options).and_return(success_response)
      allow(Trs::Client::Request).to receive(:patch).with(url, options).and_return(failure_response)
    end

    it "calls get method and handles response" do
      expect(Trs::Client::Request).to receive(:get).with(url, options)
      result = Trs::Client.get(url, options)
      expect(result).to eq({ "key" => "value" })
    end

    it "calls put method and handles response" do
      expect(Trs::Client::Request).to receive(:put).with(url, options)
      result = Trs::Client.put(url, options)
      expect(result).to eq({ "key" => "value" })
    end

    it "calls post method and handles response" do
      expect(Trs::Client::Request).to receive(:post).with(url, options)
      result = Trs::Client.post(url, options)
      expect(result).to eq({ "key" => "value" })
    end

    it "calls patch method and raises error on failure" do
      expect(Trs::Client::Request).to receive(:patch).with(url, options)
      expect {
        Trs::Client.patch(url, options)
      }.to raise_error(Trs::Client::HttpError, /status: 500/)
    end
  end
end
