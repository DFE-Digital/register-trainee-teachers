# frozen_string_literal: true

require "rails_helper"

describe "system health check spec", :smoke do
  describe "GET /healthcheck" do
    let(:endpoint) { "#{Settings.base_url}/healthcheck" }

    it "returns HTTP success" do
      get(endpoint)

      expect(response.status).to eq(200)
    end

    it "returns JSON" do
      get(endpoint)
      expect(response.media_type).to eq("application/json")
    end

    it "returns the expected response report" do
      get(endpoint)

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
