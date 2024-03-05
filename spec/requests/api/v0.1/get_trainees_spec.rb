# frozen_string_literal: true

require "rails_helper"

describe "`GET /trainees` endpoint" do
  let(:token) { "trainee_token" }
  let(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }

  let!(:start_academic_cycle) { create(:academic_cycle) }
  let!(:trainees) { create_list(:trainee, 10, provider: auth_token.provider, start_academic_cycle: start_academic_cycle) }

  it_behaves_like "a register API endpoint", "/api/v0.1/trainees", "trainee_token"

  context "filtering by academic cycle" do
    it "returns trainees for the specified academic cycle" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { academic_cycle: start_academic_cycle.start_year },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(trainees.count)
    end
  end

  context "filtering by 'since' date" do
    it "returns trainees updated after the specified date" do
      trainees.first(5).each { |t| t.touch(:updated_at) }
      since_date = 1.day.ago.to_date

      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { since: since_date },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to be >= 5
    end
  end

  context "with pagination parameters" do
    let(:per_page) { 5 }

    it "paginates the results according to 'page' and 'per_page' parameters" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { page: 1, per_page: per_page },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(per_page)
      expect(response.parsed_body["meta"]["total_count"]).to eq(trainees.count)
    end
  end

  context "filtering by state" do
    let!(:submitted_trainees) { create_list(:trainee, 5, :deferred, provider: auth_token.provider, start_academic_cycle: start_academic_cycle) }

    it "returns trainees with the specified state when a valid state is provided" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { status: "deferred" },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(submitted_trainees.count)
    end

    it "returns all trainees when an invalid state is provided" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { status: "invalid_state" },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(trainees.count + submitted_trainees.count)
    end

    it "returns all trainees when no state is provided" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" }
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(trainees.count + submitted_trainees.count)
    end
  end
end
