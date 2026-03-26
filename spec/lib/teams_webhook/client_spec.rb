# frozen_string_literal: true

require "rails_helper"

module TeamsWebhook
  describe Client do
    describe "Request" do
      it "includes the correct headers" do
        headers = Client::Request.headers
        expect(headers["Content-Type"]).to eq("application/json; charset=utf-8")
      end
    end

    describe ".post" do
      let(:url) { "https://example.com/webhook" }
      let(:options) { { body: { text: "message" }.to_json } }
      let(:success_response) { double("response", success?: true, code: 200, body: "ok", headers: {}) }
      let(:failure_response) { double("response", success?: false, code: 500, body: "error", headers: {}) }

      it "posts and returns the response on success" do
        allow(Client::Request).to receive(:post).with(url, options).and_return(success_response)

        expect(Client::Request).to receive(:post).with(url, options)
        expect(Client.post(url, options)).to eq(success_response)
      end

      it "raises HttpError on failure" do
        allow(Client::Request).to receive(:post).with(url, options).and_return(failure_response)

        expect {
          Client.post(url, options)
        }.to raise_error(Client::HttpError, /status: 500/)
      end
    end
  end
end
