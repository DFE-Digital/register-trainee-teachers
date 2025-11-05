# frozen_string_literal: true

require "rails_helper"

describe "`POST /api/v2025.0/trainees` endpoint", time_sensitive: true do
  let!(:auth_token) { create(:authentication_token) }
  let(:token) { auth_token.token }

  let(:params) { { data: } }

  let(:graduation_year) { "2003" }
  let(:course_age_range) { "13918" }
  let(:sex) { Hesa::CodeSets::Sexes::MAPPING.keys.sample }
  let(:trainee_start_date) { itt_start_date }
  let(:itt_start_date) { "2024-10-01" }
  let(:itt_end_date) { "2025-08-01" }
  let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]] }
  let(:disability1) { "58" }
  let(:disability2) { "57" }
  let(:fund_code) { Hesa::CodeSets::FundCodes::NOT_ELIGIBLE }
  let(:funding_method) { Hesa::CodeSets::BursaryLevels::NONE }
  let(:course_subject_one) { Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::MATHEMATICS] }

  let(:endpoint) { "/api/v2025.0/trainees" }

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

  # rubocop:disable RSpec/BeforeAfterAll
  before(:all) do
    Rails.application.load_seed
  end

  after(:all) do
    Rake::Task["db:truncate_all"].invoke
  end
  # rubocop:enable RSpec/BeforeAfterAll

  context "when the request is valid" do
    it "creates a trainee" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to be_successful
      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::NONE)
    end
  end

  context "when the request is valid and includes a postgrad bursary" do
    let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY }

    it "creates a trainee with a bursary" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to be_successful
      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY)
    end
  end

  context "when the request is invalid because the fund code is not eligible but everything else is correct" do
    let(:fund_code) { Hesa::CodeSets::FundCodes::NOT_ELIGIBLE }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY }

    it "does not create a trainee with a bursary and returns an error" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body[:errors]).to contain_exactly("funding_method 'bursary' is not allowed when fund_code is '2' and course_subject_one is 'mathematics'")
    end
  end

  context "when the request is invalid because no funding exists for the combination of academic_cycle, funding_method, course_subject_one, and training_route" do
    let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::SCHOLARSHIP }
    let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_postgrad]] }
    let(:course_subject_one) { Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::PSYCHOLOGY] }

    it "does not create a trainee with a bursary and returns an error" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body[:errors]).to contain_exactly(
        "funding_method 'scholarship' is not allowed when training_route is 'provider_led_postgrad' and course_subject_one is 'psychology' in academic cycle '2024 to 2025'",
      )
    end
  end

  context "when the request is valid and includes a undergrad bursary" do
    let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::UNDERGRADUATE_BURSARY }
    let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]] }

    it "creates a trainee with a bursary" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to be_successful
      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::UNDERGRADUATE_BURSARY)
    end
  end

  context "when the request is valid and includes a tier one bursary" do
    let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::TIER_ONE }
    let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]] }

    it "creates a trainee with a bursary" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to be_successful
      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::TIER_ONE)
    end
  end

  context "when the request is valid and includes a tier two bursary" do
    let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::TIER_TWO }
    let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]] }

    it "creates a trainee with a bursary" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to be_successful
      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::TIER_TWO)
    end
  end

  context "when the request is valid and includes a tier three bursary" do
    let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::TIER_THREE }
    let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]] }

    it "creates a trainee with a bursary" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to be_successful
      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::TIER_THREE)
    end
  end

  context "when the request is valid and includes a veterans bursary" do
    let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::VETERAN_TEACHING_UNDERGRADUATE_BURSARY }
    let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]] }

    it "creates a trainee with a bursary" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to be_successful
      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::VETERAN_TEACHING_UNDERGRADUATE_BURSARY)
    end
  end

  context "when the request is valid and includes a scholarship" do
    let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::SCHOLARSHIP }
    let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_postgrad]] }
    let(:course_subject_one) { Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::PHYSICS] }

    it "creates a trainee with a scholarship" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to be_successful
      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::SCHOLARSHIP)
    end
  end

  context "when the request is valid and includes a grant" do
    let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::GRANT }
    let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:school_direct_salaried]] }
    let(:course_subject_one) { Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::MUSIC_EDUCATION_AND_TEACHING] }

    it "creates a trainee with a grant" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to be_successful
      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::GRANT)
    end
  end
end
