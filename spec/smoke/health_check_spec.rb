# frozen_string_literal: true

require "spec_helper_smoke"

describe "system health check spec", smoke: true do
  describe "GET /healthcheck" do
    let(:endpoint) { "#{Settings.base_url}/healthcheck" }

    subject(:response) { HTTParty.get(endpoint) }

    it "returns HTTP success" do
      expect(response.code).to eq(200)
    end

    it "returns the expected response report" do
      expect(response.body).to eq(
        {
          checks: {
            database: true,
            redis: true,
            sidekiq_processes: true,
          },
        }.to_json,
      )
    end
  end
end
