# frozen_string_literal: true

require "rails_helper"

module Rotp
  RSpec.describe Providers do
    describe ".path" do
      it "matches the versioned providers route" do
        expect(described_class.path).to eq("/#{Settings.rotp.api_version}/providers")
      end
    end

    describe ".list" do
      let(:payload) { { "data" => [{ "code" => "X01" }] } }
      let(:response) { double(parsed_response: payload) }

      before do
        allow(Client).to receive(:get).and_return(response)
      end

      it "GETs the providers index and returns the data array" do
        expect(described_class.list).to eq(payload["data"])
        expect(Client).to have_received(:get).with(described_class.path)
      end
    end
  end
end
