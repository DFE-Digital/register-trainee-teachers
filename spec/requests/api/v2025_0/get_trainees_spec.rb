# frozen_string_literal: true

require "rails_helper"

describe "`GET /trainees` endpoint" do
  let(:auth_token) { create(:authentication_token) }
  let(:token) { auth_token.token }

  let!(:start_academic_cycle) { create(:academic_cycle) }
  let!(:trainees) { create_list(:trainee, 10, :with_hesa_trainee_detail, :trn_received, provider: auth_token.provider, start_academic_cycle: start_academic_cycle) }

  it_behaves_like "a register API endpoint", "/api/v2025.0/trainees"

  context "filtering out draft trainees" do
    let!(:draft_trainee) { create(:trainee, :draft, :with_hesa_trainee_detail) }

    it "only returns non-draft trainees" do
      get(
        "/api/v2025.0/trainees",
        headers: { Authorization: "Bearer #{token}" },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(trainees.count)
    end
  end

  context "filtering by academic cycle" do
    it "returns trainees for the specified academic cycle" do
      get(
        "/api/v2025.0/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { academic_cycle: start_academic_cycle.start_year },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(trainees.count)
    end

    it "returns status code 422 if academic cycle filter is invalid" do
      get(
        "/api/v2025.0/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { academic_cycle: "not-a-number" },
      )

      expect(response.parsed_body).to eq(
        "message" => "Validation failed: 1 error prohibited this request being run",
        "errors" => {
          "academic_cycle" => ["not-a-number is not a valid academic cycle year"],
        },
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
        "/api/v2025.0/trainees",
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
        "/api/v2025.0/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { since: since_date },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to be 8

      expected_trainees.each do |trainee|
        expect(response.parsed_body["data"]).to include(include("trainee_id" => trainee.slug))
      end
    end

    it "returns status code 422 if since filter is an invalid date" do
      get(
        "/api/v2025.0/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { since: "2023-13-01" },
      )

      expect(response).to have_http_status(:unprocessable_entity)

      expect(response.parsed_body).to eq(
        "message" => "Validation failed: 1 error prohibited this request being run",
        "errors" => {
          "since" => ["2023-13-01 is not a valid date"],
        },
      )
    end
  end

  context "with pagination parameters" do
    let(:per_page) { 5 }

    it "paginates the results according to 'page' and 'per_page' parameters" do
      get(
        "/api/v2025.0/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { page: 1, per_page: per_page },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(per_page)
      expect(response.parsed_body["meta"]["total_count"]).to eq(trainees.count)
    end
  end

  context "with sort order", time_sensitive: true do
    it "sorts the results in descending order by default" do
      get(
        "/api/v2025.0/trainees",
        headers: { Authorization: "Bearer #{token}" },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].map { |trainee| trainee[:trainee_id] }).to eq(trainees.map(&:slug).reverse)
    end

    it "sorts the results in ascending order when specified" do
      get(
        "/api/v2025.0/trainees",
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
        "/api/v2025.0/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { status: "deferred" },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(submitted_trainees.count)
    end

    it "returns status code 422 when an invalid state is provided" do
      get(
        "/api/v2025.0/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: { status: "invalid_state" },
      )

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to eq(
        "message" => "Validation failed: 1 error prohibited this request being run",
        "errors" => {
          "status" => ["invalid_state is not a valid status"],
        },
      )
    end

    it "returns all trainees when no state is provided" do
      get(
        "/api/v2025.0/trainees",
        headers: { Authorization: "Bearer #{token}" },
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].count).to eq(trainees.count + submitted_trainees.count)
    end
  end

  context "filtering by trn" do
    let!(:trainees_without_trn) { create_list(:trainee, 2, :submitted_for_trn, provider: auth_token.provider) }

    before do
      get(
        "/api/v2025.0/trainees",
        headers: { Authorization: "Bearer #{token}" },
        params: params,
      )
    end

    context "with has_trn" do
      let(:params) { { has_trn: } }

      context "when has_turn is true" do
        let(:has_trn) { true }

        it "returns the trainees with a trn" do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["data"].count).to eq(10)
          expect(response.parsed_body["data"].map { |trainee| trainee[:trainee_id] })
            .to match_array(trainees.pluck(:slug))
        end
      end

      context "when has_trn is false" do
        let(:has_trn) { false }

        it "return the trainees without a trn" do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["data"].count).to eq(2)
          expect(response.parsed_body["data"].map { |trainee| trainee[:trainee_id] })
            .to match_array(trainees_without_trn.pluck(:slug))
        end
      end

      context "when has_trn is nil" do
        let(:has_trn) { nil }

        it "returns all the trainees", openapi: false do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["data"].count).to eq(12)
          expect(response.parsed_body["data"].map { |trainee| trainee[:trainee_id] })
            .to match_array(trainees.pluck(:slug) + trainees_without_trn.pluck(:slug))
        end
      end

      context "when has_trn is empty" do
        let(:has_trn) { "" }

        it "returns all the trainees", openapi: false do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["data"].count).to eq(12)
          expect(response.parsed_body["data"].map { |trainee| trainee[:trainee_id] })
            .to match_array(trainees.pluck(:slug) + trainees_without_trn.pluck(:slug))
        end
      end
    end

    context "without has_trn" do
      let(:params) { {} }

      it "returns all the trainees" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"].count).to eq(12)
        expect(response.parsed_body["data"].map { |trainee| trainee[:trainee_id] })
          .to match_array(trainees.pluck(:slug) + trainees_without_trn.pluck(:slug))
      end
    end
  end
end
