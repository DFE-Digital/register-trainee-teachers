# frozen_string_literal: true

require "rails_helper"

describe "`POST /api/v1.0-pre/trainees` endpoint" do
  let(:token) { "trainee_token" }
  let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }

  let(:params) { { data: } }

  let(:graduation_year) { "2003" }
  let(:course_age_range) { "13918" }
  let(:sex) { Hesa::CodeSets::Sexes::MAPPING.keys.sample }
  let(:trainee_start_date) { itt_start_date }
  let(:itt_start_date) { "2023-01-01" }
  let(:itt_end_date) { "2023-10-01" }
  let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]] }
  let(:disability1) { "58" }
  let(:disability2) { "57" }
  let(:fund_code) { Hesa::CodeSets::FundCodes::NOT_ELIGIBLE }
  let(:funding_method) { Hesa::CodeSets::BursaryLevels::NONE }
  let(:course_subject_one) { Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::MATHEMATICS] }

  let(:endpoint) { "/api/v1.0-pre/trainees" }

  let(:data) do
    {
      first_names: "John",
      last_name: "Doe",
      previous_last_name: "Smith",
      date_of_birth: "1990-01-01",
      sex: sex,
      email: "john.doe@example.com",
      nationality: "GB",
      training_route: training_route,
      itt_start_date: itt_start_date,
      itt_end_date: itt_end_date,
      course_subject_one: course_subject_one,
      study_mode: Hesa::CodeSets::StudyModes::MAPPING.invert[TRAINEE_STUDY_MODE_ENUMS["full_time"]],
      disability1: disability1,
      disability2: disability2,
      degrees_attributes: [
        {
          grade: "02",
          subject: "100485",
          institution: "0117",
          uk_degree: "083",
          graduation_year: graduation_year,
        },
      ],
      placements_attributes: [
        {
          name: "Placement",
          urn: "900020",
        },
      ],
      itt_aim: "202",
      itt_qualification_aim: "001",
      course_year: "2012",
      course_age_range: course_age_range,
      fund_code: fund_code,
      funding_method: funding_method,
      hesa_id: "0310261553101",
      provider_trainee_id: "99157234/2/01",
      pg_apprenticeship_start_date: "2024-03-11",
    }
  end

  before do
    Rails.application.load_seed
  end

  context "when the request is valid" do
    it "creates a trainee" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to be_successful
      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:previous_last_name]).to eq("Smith")
      expect(response.parsed_body[:data][:pg_apprenticeship_start_date]).to eq("2024-03-11")
    end
  end

  context "when the request is valid and includes a bursary" do
    let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY }

    it "creates a trainee with a bursary" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to be_successful
      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:previous_last_name]).to eq("Smith")
      expect(response.parsed_body[:data][:pg_apprenticeship_start_date]).to eq("2024-03-11")
    end
  end
end
