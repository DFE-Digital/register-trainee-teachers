# frozen_string_literal: true

require "rails_helper"

describe "`PUT /api/v2027.0/trainees/:id` endpoint", time_sensitive: true do
  let!(:auth_token) { create(:authentication_token) }
  let(:token) { auth_token.token }
  let(:headers) { { Authorization: token, **json_headers } }

  let(:academic_cycle) { AcademicCycle.for_year(2027) }
  let(:allocation_subject) { AllocationSubject.find_by!(name: AllocationSubjects::CHEMISTRY) }
  let(:degree_subject) { "100417" }
  let(:slug) { response.parsed_body[:data][:trainee_id] }

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
        degrees_attributes: [
          {
            grade: "02",
            subject: degree_subject,
            institution: "0117",
            uk_degree: "083",
            graduation_year: "2003",
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
        course_age_range: "13918",
        fund_code: Hesa::CodeSets::FundCodes::NOT_ELIGIBLE,
        funding_method: Hesa::CodeSets::BursaryLevels::NONE,
        hesa_id: "0310261553101",
        provider_trainee_id: "99157234/2/01",
      },
    }
  end

  let(:params_for_update) do
    {
      data: {
        fund_code: Hesa::CodeSets::FundCodes::ELIGIBLE,
        funding_method: Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY,
      },
    }
  end

  before do
    Rails.application.load_seed

    funding_method = create(
      :funding_method,
      academic_cycle: academic_cycle,
      training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
      funding_type: FUNDING_TYPE_ENUMS[:bursary],
      degree_relevance: "relevant",
    )
    create(:funding_method_subject, funding_method:, allocation_subject:)
    create(:relevant_degree_subject, academic_cycle: academic_cycle, allocation_subject: allocation_subject, hecos_code: "100417")

    post "/api/v2027.0/trainees", params: params_for_create.to_json, headers: headers
  end

  context "when updating to a bursary that is only for a relevant degree" do
    context "with a relevant degree" do
      it "updates the trainee with a bursary" do
        put "/api/v2027.0/trainees/#{slug}", params: params_for_update.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY)
      end
    end

    context "with an unrelated degree" do
      let(:degree_subject) { "100302" }

      it "does not update the trainee and returns an error" do
        put "/api/v2027.0/trainees/#{slug}", params: params_for_update.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly(
          "funding_method 'bursary' is not allowed when training_route is 'provider_led_postgrad' and course_subject_1 is 'chemistry' in academic cycle '2027 to 2028'",
        )
        expect(Trainee.find_by(slug:).hesa_trainee_detail.funding_method).to eq(Hesa::CodeSets::BursaryLevels::NONE)
      end
    end
  end
end
