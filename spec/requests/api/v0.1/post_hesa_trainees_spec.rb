# frozen_string_literal: true

require "rails_helper"

describe "`POST /api/v0.1/trainees` endpoint" do
  let(:token) { "trainee_token" }
  let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
  let!(:nationality) { create(:nationality, :british) }

  let!(:course_allocation_subject) do
    create(:subject_specialism, name: CourseSubjects::BIOLOGY).allocation_subject
  end

  let(:params) do
    {
      data: {
        first_names: "John",
        last_name: "Doe",
        date_of_birth: "1990-01-01",
        sex: Hesa::CodeSets::Sexes::MAPPING.invert[Trainee.sexes[:male]],
        email: "john.doe@example.com",
        nationality: "GB",
        training_route: Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]],
        itt_start_date: "2023-01-01",
        itt_end_date: "2023-10-01",
        course_subject_one: Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::BIOLOGY],
        study_mode: Hesa::CodeSets::StudyModes::MAPPING.invert[TRAINEE_STUDY_MODE_ENUMS["full_time"]],
      },
    }
  end

  context "when the request is valid", feature_register_api: true do
    before do
      allow(Api::MapHesaAttributes::V01).to receive(:call).and_call_original

      post "/api/v0.1/trainees", params: params, headers: { Authorization: token }
    end

    it "calls the Hesa::MapHesaAttributes service" do
      expected_params = ActionController::Parameters.new(
        params[:data].slice(*(Api::MapHesaAttributes::V01::ATTRIBUTES + Api::TraineeAttributes::V01::ATTRIBUTES)),
      ).permit!

      expect(Api::MapHesaAttributes::V01).to have_received(:call).with(params: expected_params)
    end

    it "creates a trainee" do
      expect(response.parsed_body["first_names"]).to eq("John")
    end

    it "returns status code 201" do
      expect(response).to have_http_status(:created)
    end

    it "creates the nationalities" do
      expect(Trainee.last.nationalities.first.name).to eq("british")
    end

    it "sets the correct course allocation subject" do
      expect(Trainee.last.course_allocation_subject).to eq(course_allocation_subject)
    end

    it "sets the progress data structure" do
      expect(Trainee.last.progress.personal_details).to be(true)
    end

    it "sets the record source to `api`" do
      expect(Trainee.last.record_source).to eq("api")
    end
  end

  context "when the request is invalid", feature_register_api: true do
    before do
      post "/api/v0.1/trainees", params: { data: { email: "Doe" } }, headers: { Authorization: token }
    end

    it "returns status code 422" do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns a validation failure message" do
      expect(response.parsed_body["errors"]).to include("First names can't be blank")
      expect(response.parsed_body["errors"]).to include("Last name can't be blank")
      expect(response.parsed_body["errors"]).to include("Date of birth can't be blank")
      expect(response.parsed_body["errors"]).to include("Sex can't be blank")
      expect(response.parsed_body["errors"]).to include("Training route can't be blank")
      expect(response.parsed_body["errors"]).to include("Itt start date can't be blank")
      expect(response.parsed_body["errors"]).to include("Itt end date can't be blank")
      expect(response.parsed_body["errors"]).to include("Course subject one can't be blank")
      expect(response.parsed_body["errors"]).to include("Study mode can't be blank")
      expect(response.parsed_body["errors"]).to include("Email Enter an email address in the correct format, like name@example.com")
    end
  end
end
