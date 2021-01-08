# frozen_string_literal: true

require "rails_helper"

describe "system health check spec", :smoke_test do
  describe "GET /healthcheck" do
    it "returns HTTP success" do
      get "/healthcheck"

      expect(response.status).to eq(200)
    end

    it "returns JSON" do
      get "/healthcheck"
      expect(response.media_type).to eq("application/json")
    end

    it "returns the expected response report" do
      get "/healthcheck"

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
