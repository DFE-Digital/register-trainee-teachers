# frozen_string_literal: true

require "rails_helper"

RSpec.describe Fauapi::Client do
  let(:base_url) { Settings.fauapi.base_url }

  describe ".import" do
    let(:manifest) { { name: "register-trainee-teachers-api", majorVersion: "v2026" } }

    before do
      stub_request(:post, "#{base_url}/api/tasks/apis/import")
        .with(
          body: manifest.to_json,
          headers: { "Authorization" => "Bearer #{Settings.fauapi.api_key}" },
        )
        .to_return(status: 200, body: { updated: true }.to_json, headers: { "Content-Type" => "application/json" })
    end

    it "posts the manifest and returns the parsed body" do
      expect(described_class.import(manifest)).to eq("updated" => true)
    end

    context "when the request fails" do
      before do
        stub_request(:post, "#{base_url}/api/tasks/apis/import")
          .to_return(status: 500, body: "boom")
      end

      it "raises HttpError" do
        expect { described_class.import(manifest) }.to raise_error(Fauapi::Client::HttpError, /status: 500/)
      end
    end
  end

  describe ".list_apis" do
    before do
      stub_request(:get, "#{base_url}/api/tasks/apis")
        .to_return(status: 200, body: [{ id: 1, name: "register-trainee-teachers-api" }].to_json)
    end

    it "returns the parsed list" do
      expect(described_class.list_apis).to eq([{ "id" => 1, "name" => "register-trainee-teachers-api" }])
    end
  end

  describe ".publish" do
    before do
      stub_request(:put, "#{base_url}/api/tasks/apis/42/publish")
        .to_return(status: 204, body: "")
    end

    it "accepts an empty 204 body" do
      expect(described_class.publish(42)).to eq({})
    end
  end
end
