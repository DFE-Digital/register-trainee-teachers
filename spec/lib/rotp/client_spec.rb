# frozen_string_literal: true

require "rails_helper"

module Rotp
  RSpec.describe Client do
    describe ".get" do
      let(:path) { "/example" }
      let(:response) { double(code: 200, body: '{"data":[]}', headers: {}) }

      before do
        allow(Client::Request).to receive(:get).and_return(response)
      end

      it "returns the response" do
        expect(described_class.get(path)).to eq(response)
      end

      context "when the response is not 200" do
        let(:response) { double(code: 401, body: '{"error":"Unauthorized"}', headers: {}) }

        it "raises an HttpError" do
          expect { described_class.get(path) }.to raise_error(Client::HttpError, /status: 401/)
        end
      end
    end
  end
end
