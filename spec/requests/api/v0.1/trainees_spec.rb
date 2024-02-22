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
        parsed_trainee = JSON.parse(TraineeSerializer.new(trainee).as_hash.to_json)
        expect(response.parsed_body).to eq(parsed_trainee)
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
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Trainee(s) not found" })
      end
    end
  end

  describe "POST /api/v0.1/trainees" do
    let(:valid_attributes) do
      {
        data: {
          first_names: "John",
          middle_names: "James",
          last_name: "Doe",
          date_of_birth: "1990-01-01",
          sex: "male",
          email: "john.doe@example.com",
          trn: "123456",
          training_route: "assessment_only",
          itt_start_date: "2022-09-01",
          itt_end_date: "2023-07-01",
          diversity_disclosure: "diversity_disclosed",
          ethnic_group: "white_ethnic_group",
          ethnic_background: "Background 1",
          disability_disclosure: "no_disability",
          course_subject_one: "Maths",
          course_subject_two: "Science",
          course_subject_three: "English",
          study_mode: "full_time",
          application_choice_id: "123",
          placements_attributes: [{ urn: "123456", name: "Placement" }],
          degrees_attributes: [{ country: "UK", grade: "First", subject: "Computer Science", institution: "University of Test", graduation_year: "2012", locale_code: "uk" }],
        },
      }
    end

    before { create(:provider) }

    context "when the request is valid", feature_register_api: true do
      before do
        api_post 0.1, :trainees, params: valid_attributes, token: "Bearer #{token}"
      end

      it "creates a trainee" do
        expect(response.parsed_body["first_names"]).to eq("John")
      end

      it "creates associated placements" do
        expect(response.parsed_body["placements"].first["urn"]).to eq("123456")
      end

      it "creates associated degrees" do
        expect(response.parsed_body["degrees"].first["country"]).to eq("UK")
      end

      it "returns status code 201" do
        expect(response).to have_http_status(:created)
      end
    end

    context "when the request is invalid", feature_register_api: true do
      before do
        api_post 0.1, :trainees, params: { data: { last_name: "Doe" } }, token: "Bearer #{token}"
      end

      it "returns status code 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns a validation failure message" do
        expect(response.parsed_body["errors"]).to include("First names can't be blank")
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

    context "filtering by state" do
      let!(:submitted_trainees) { create_list(:trainee, 5, :submitted_for_trn, provider: auth_token.provider, start_academic_cycle: start_academic_cycle) }

      it "returns trainees with the specified state when a valid state is provided" do
        api_get 0.1, :trainees, params: { state: 'submitted_for_trn' }, token: token

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"].count).to eq(submitted_trainees.count)
      end

      it "returns no trainees when an invalid state is provided" do
        api_get 0.1, :trainees, params: { state: 'invalid_state' }, token: token

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body["data"]).to be_nil
      end

      it "returns all trainees when no state is provided" do
        api_get 0.1, :trainees, token: token

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"].count).to eq(trainees.count + submitted_trainees.count)
      end
    end
  end
end
