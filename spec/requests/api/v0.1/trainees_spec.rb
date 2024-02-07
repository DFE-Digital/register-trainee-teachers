# frozen_string_literal: true

require "rails_helper"

describe "Trainees API" do
  let(:token) { "trainee_token" }
  let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }

  describe "GET /api/v0.1/trainees/:id" do
    let!(:trainee) { create(:trainee, slug: "12345", provider: auth_token.provider) }

    it_behaves_like "a register API endpoint", "/api/v0.1/trainees/12345", "trainee_token"

    context "when the trainee exists", feature_register_api: true do
      before do
        api_get 0.1, "/trainees/#{trainee.slug}", token:
      end

      it "returns the trainee" do
        expect(response.parsed_body).to eq(JSON.parse(trainee.to_json))
      end

      it "returns status code 200" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the trainee does not exist", feature_register_api: true do
      before do
        api_get 0.1, "/trainees/nonexistent", token:
      end

      it "returns status code 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns a not found message" do
        expect(response.parsed_body["error"]).to eq("Trainee not found")
      end
    end
  end

  describe "GET /trainees", feature_register_api: true do
    let!(:start_academic_cycle) { create(:academic_cycle) }
    let!(:trainees) { create_list(:trainee, 10, provider: auth_token.provider, start_academic_cycle: start_academic_cycle) }

    it_behaves_like "a register API endpoint", "/api/v0.1/trainees", "trainee_token"

    context "filtering by academic cycle" do
      it "returns trainees for the specified academic cycle" do
        api_get 0.1, :trainees, params: { academic_cycle: start_academic_cycle.start_year }, token: token

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"].count).to eq(trainees.count)
      end
    end

    context "filtering by 'since' date" do
      it "returns trainees updated after the specified date" do
        trainees.first(5).each { |t| t.touch(:updated_at) }
        since_date = 1.day.ago.to_date

        api_get 0.1, :trainees, params: { since: since_date }, token: token

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"].count).to be >= 5
      end
    end

    context "with pagination parameters" do
      let(:per_page) { 5 }

      it "paginates the results according to 'page' and 'per_page' parameters" do
        api_get 0.1, :trainees, params: { page: 1, per_page: per_page }, token: token

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"].count).to eq(per_page)
        expect(response.parsed_body["meta"]["total_count"]).to eq(trainees.count)
      end
    end
  end
end
