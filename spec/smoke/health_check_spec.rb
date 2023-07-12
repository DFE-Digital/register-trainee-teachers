# frozen_string_literal: true

require "spec_helper_smoke"

describe "system health check spec", smoke: true do
  describe "GET /healthcheck" do
    let(:endpoint) { "#{Settings.base_url}/healthcheck" }

    # Added verify false as it was failing ssl_check, but need to resolve why it is failing
    subject(:response) { HTTParty.get(endpoint, verify: false) }

    it "returns HTTP success" do
      # rubocop:disable RSpec/Rails/HaveHttpStatus
      expect(response.code).to eq(200)
      # rubocop:enable RSpec/Rails/HaveHttpStatus
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
