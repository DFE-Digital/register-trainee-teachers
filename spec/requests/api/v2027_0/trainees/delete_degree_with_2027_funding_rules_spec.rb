# frozen_string_literal: true

require "rails_helper"

describe "`DELETE /trainees/:trainee_slug/degrees/:slug` endpoint", time_sensitive: true do
  let!(:auth_token) { create(:authentication_token) }
  let(:token) { auth_token.token }
  let(:headers) { { Authorization: token, **json_headers } }

  let(:academic_cycle) { AcademicCycle.for_year(2027) }
  let(:allocation_subject) { AllocationSubject.find_by!(name: AllocationSubjects::CHEMISTRY) }
  let(:funding_method) { Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY }
  let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }
  let(:funding_error) do
    "funding_method 'bursary' is not allowed when training_route is 'provider_led_postgrad' and course_subject_1 is 'chemistry' in academic cycle '2027 to 2028'"
  end

  let(:trainee_slug) { response.parsed_body[:data][:trainee_id] }
  let(:degree_slug) { response.parsed_body[:data][:degrees].first[:degree_id] }

  let(:chemistry_degree) do
    {
      grade: "02",
      subject: "100417",
      institution: "0117",
      uk_degree: "083",
      graduation_year: "2003",
    }
  end
  let(:history_degree) { chemistry_degree.merge(subject: "100302", graduation_year: "2005") }

  let(:params_for_create) do
    {
      data: {
        first_names: "John",
        last_name: "Doe",
        previous_last_name: "Smith",
        date_of_birth: "1990-01-01",
        sex: Hesa::CodeSets::Sexes::MAPPING.keys.sample,
        email: "john.doe@example.com",
        nationality: "GB",
        training_route: Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_postgrad]],
        itt_start_date: "2027-09-01",
        itt_end_date: "2028-07-31",
        course_subject_1: Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::CHEMISTRY],
        study_mode: Hesa::CodeSets::StudyModes::MAPPING.invert[TRAINEE_STUDY_MODE_ENUMS["full_time"]],
        disability1: "58",
        degrees_attributes: [chemistry_degree],
        placements_attributes: [
          {
            name: "Placement",
            urn: "900020",
          },
        ],
        itt_aim: "202",
        itt_qualification_aim: "001",
        course_year: "2012",
        course_age_range: "13918",
        fund_code: fund_code,
        funding_method: funding_method,
        hesa_id: "0310261553101",
        provider_trainee_id: "99157234/2/01",
      },
    }
  end

  before do
    Rails.application.load_seed

    funding_rule = create(
      :funding_method,
      academic_cycle: academic_cycle,
      training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
      funding_type: FUNDING_TYPE_ENUMS[:bursary],
      degree_relevance: "relevant",
    )
    create(:funding_method_subject, funding_method: funding_rule, allocation_subject: allocation_subject)
    create(:relevant_degree_subject, academic_cycle: academic_cycle, allocation_subject: allocation_subject, hecos_code: "100417")

    post "/api/v2027.0/trainees", params: params_for_create.to_json, headers: headers
  end

  context "when the trainee has a bursary that is only for a relevant degree" do
    context "with the relevant degree deleted" do
      it "does not delete the degree and returns an error" do
        slug = trainee_slug
        chemistry_slug = degree_slug
        post "/api/v2027.0/trainees/#{slug}/degrees", params: { data: history_degree }.to_json, headers: headers

        delete("/api/v2027.0/trainees/#{slug}/degrees/#{chemistry_slug}", headers:)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly(funding_error)
        expect(Trainee.find_by!(slug:).degrees.count).to eq(2)
      end
    end

    context "with the only degree deleted" do
      it "does not delete the degree and returns an error" do
        slug = trainee_slug

        delete("/api/v2027.0/trainees/#{slug}/degrees/#{degree_slug}", headers:)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly(funding_error)
        expect(Trainee.find_by!(slug:).degrees.count).to eq(1)
      end
    end
  end

  context "when the trainee has no funding" do
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::NONE }
    let(:fund_code) { Hesa::CodeSets::FundCodes::NOT_ELIGIBLE }

    context "with the only degree deleted" do
      it "deletes the degree" do
        slug = trainee_slug

        delete("/api/v2027.0/trainees/#{slug}/degrees/#{degree_slug}", headers:)

        expect(response).to have_http_status(:ok)
        expect(Trainee.find_by!(slug:).degrees.count).to eq(0)
      end
    end
  end
end
