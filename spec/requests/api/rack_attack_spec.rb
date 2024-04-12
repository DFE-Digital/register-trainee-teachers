# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rack::Attack settings" do
  before do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  after do
    Rack::Attack.cache.store = ActiveSupport::Cache::NullStore.new
  end

  describe "Rate limiting" do
    let(:provider) { create(:provider) }
    let!(:token) { AuthenticationToken.create_with_random_token(provider:) }

    let(:limit) { 100 }

    context "when requests per IP > 100" do
      %W[#{Faker::Internet.ip_v4_address}].each do |ip|
        it "limits the amount of requests" do
          (limit + 1).times do
            get "/api/v0.1/info", headers: {
                                    authorization: "Bearer #{token}",
                                  },
                                  env: { REMOTE_ADDR: ip }
          end

          expect(response).to have_http_status(:too_many_requests)
          expect(response.body).to match("Retry later")
        end
      end
    end

    context "when requests per IP <= 100" do
      %W[#{Faker::Internet.ip_v4_address} #{Faker::Internet.ip_v4_address}].each do |ip|
        it "does not limit the amount of requests" do
          limit.times do
            get "/api/v0.1/info", headers: {
                                    authorization: "Bearer #{token}",
                                  },
                                  env: { REMOTE_ADDR: ip }
          end

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
