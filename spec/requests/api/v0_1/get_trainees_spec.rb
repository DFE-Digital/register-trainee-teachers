# frozen_string_literal: true

require "rails_helper"

describe "`GET /trainees` endpoint" do
  let(:token) { "trainee_token" }
  let(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }

  let!(:start_academic_cycle) { create(:academic_cycle) }
  let!(:trainees) { create_list(:trainee, 10, :with_hesa_trainee_detail, :trn_received, provider: auth_token.provider, start_academic_cycle: start_academic_cycle) }

  it_behaves_like "a register API endpoint", "/api/v0.1/trainees", "trainee_token"

  context "filtering out draft trainees" do
    let!(:draft_trainee) { create(:trainee, :draft, :with_hesa_trainee_detail) }

    it "only returns non-draft trainees" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(trainees.count)
    end
  end

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

    it "returns 422 if academic cycle filter is invalid" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { academic_cycle: "not-a-number" },
      )

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context "filtering by 'since' date" do
    it "returns trainees updated after the specified date" do
      since_date = "2024-03-15T13:15:37.880Z"

      trainees.first(2).each { |t| t.update!(updated_at: "2024-03-15T12:15:37.879Z") }

      expected_trainees = trainees.drop(2).each_with_index { |t, i| t.update!(updated_at: "2024-03-15T13:15:37.88#{i + 1}Z") }

      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { since: since_date },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to be 8

      expected_trainees.each do |trainee|
        expect(response.parsed_body["data"]).to include(include("trainee_id" => trainee.slug))
      end
    end

    it "returns trainees updated on the specified date" do
      since_date = "2024-03-15T13:15:37.880Z"

      trainees.first(2).each { |t| t.update!(updated_at: "2024-03-15T12:15:37.879Z") }

      expected_trainees = trainees.drop(2).each { |t| t.update!(updated_at: since_date) }

      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { since: since_date },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to be 8

      expected_trainees.each do |trainee|
        expect(response.parsed_body["data"]).to include(include("trainee_id" => trainee.slug))
      end
    end

    it "returns 422 if since filter is an invalid date" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { since: "2023-13-01" },
      )

      expect(response).to have_http_status(:unprocessable_entity)
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

  context "with sort order" do
    it "sorts the results in descending order by default" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].map { |trainee| trainee[:trainee_id] }).to eq(trainees.map(&:slug).reverse)
    end

    it "sorts the results in ascending order when specified" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { sort_order: "asc" },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].map { |trainee| trainee[:trainee_id] }).to eq(trainees.map(&:slug))
    end
  end

  context "filtering by state" do
    let!(:submitted_trainees) { create_list(:trainee, 5, :with_hesa_trainee_detail, :deferred, provider: auth_token.provider, start_academic_cycle: start_academic_cycle) }

    it "returns trainees with the specified state when a valid state is provided" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { status: "deferred" },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(submitted_trainees.count)
    end

    it "returns 422 when an invalid state is provided" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { status: "invalid_state" },
      )

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns all trainees when no state is provided" do
      get(
        "/api/v0.1/trainees",
        headers: { Authorization: "Bearer #{token}" },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(trainees.count + submitted_trainees.count)
    end
  end
end