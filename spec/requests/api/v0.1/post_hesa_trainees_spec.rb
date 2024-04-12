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
        degrees_attributes: [
          {
            subject: "Law",
            institution: nil,
            graduation_date: "2003-06-01",
            subject_one: "100485",
            grade: "02",
            country: "XF",
          },
        ],
        placements_attributes: [
          {
            urn: "900020",
          },
        ],
        itt_aim: 202,
        itt_qualification_aim: "001",
        course_year: "2012",
        course_age_range: "13915",
        fund_code: "7",
        funding_method: "4",
        hesa_id: "0310261553101",
      },
    }
  end

  context "when the request is valid", feature_register_api: true do
    before do
      allow(Api::MapHesaAttributes::V01).to receive(:call).and_call_original
      allow(Trainees::MapFundingFromDttpEntityId).to receive(:call).and_call_original

      post "/api/v0.1/trainees", params: params, headers: { Authorization: token }
    end

    it "creates a trainee" do
      expect(response.parsed_body["first_names"]).to eq("John")
    end

    it "sets the correct state" do
      expect(Trainee.last.state).to eq("submitted_for_trn")
    end

    it "sets the correct funding attributes" do
      expect(Trainees::MapFundingFromDttpEntityId).to have_received(:call).once
    end

    it "sets the correct school attributes" do
      expect(response.parsed_body["lead_school_not_applicable"]).to be(false)
      expect(response.parsed_body["lead_school"]).to be_nil
      expect(response.parsed_body["employing_school_not_applicable"]).to be(false)
      expect(response.parsed_body["employing_school"]).to be_nil
    end

    it "creates the degrees if provided in the request body" do
      degree_attributes = response.parsed_body["degrees"]&.first

      expect(degree_attributes["subject"]).to eq("Law")
      expect(degree_attributes["institution"]).to be_nil
      expect(degree_attributes["graduation_year"]).to eq(2003)
    end

    it "creates the placements if provided in the request body" do
      placement_attributes = response.parsed_body["placements"]&.first

      expect(placement_attributes["school_id"]).to be_nil
      expect(placement_attributes["name"]).to eq("Establishment does not have a URN")
      expect(placement_attributes["urn"]).to eq("900020")
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
      expect(response.parsed_body["errors"]).to include("Itt aim can't be blank")
      expect(response.parsed_body["errors"]).to include("Itt qualification aim can't be blank")
      expect(response.parsed_body["errors"]).to include("Course year can't be blank")
      expect(response.parsed_body["errors"]).to include("Course age range can't be blank")
      expect(response.parsed_body["errors"]).to include("Fund code can't be blank")
      expect(response.parsed_body["errors"]).to include("Funding method can't be blank")
      expect(response.parsed_body["errors"]).to include("Hesa can't be blank")
    end
  end
end
