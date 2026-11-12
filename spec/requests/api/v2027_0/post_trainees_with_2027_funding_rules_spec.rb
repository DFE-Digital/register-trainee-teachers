# frozen_string_literal: true

require "rails_helper"

describe "`POST /api/v2027.0/trainees` endpoint", time_sensitive: true do
  let!(:auth_token) { create(:authentication_token) }
  let(:token) { auth_token.token }

  let(:params) { { data: } }

  let(:academic_cycle) { AcademicCycle.for_year(2027) }
  let(:allocation_subject) { AllocationSubject.find_by!(name: AllocationSubjects::CHEMISTRY) }
  let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
  let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[route] }
  let(:course_subject_one) { Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::CHEMISTRY] }
  let(:funding_method) { Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY }
  let(:degree_subject) { "100417" }
  let(:employing_school_urn) { nil }

  let(:endpoint) { "/api/v2027.0/trainees" }

  let(:data) do
    {
      first_names: "John",
      last_name: "Doe",
      previous_last_name: "Smith",
      date_of_birth: "1990-01-01",
      sex: Hesa::CodeSets::Sexes::MAPPING.keys.sample,
      email: "john.doe@example.com",
      nationality: "GB",
      training_route: training_route,
      itt_start_date: "2027-09-01",
      itt_end_date: "2028-07-31",
      course_subject_1: course_subject_one,
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
      fund_code: Hesa::CodeSets::FundCodes::ELIGIBLE,
      funding_method: funding_method,
      hesa_id: "0310261553101",
      provider_trainee_id: "99157234/2/01",
      employing_school_urn: employing_school_urn,
    }.compact
  end

  before do
    Rails.application.load_seed

    create(:relevant_degree_subject, academic_cycle: academic_cycle, allocation_subject: allocation_subject, hecos_code: "100417")
  end

  def create_funding_rule(funding_type:, **conditions)
    funding_rule = create(:funding_method, academic_cycle: academic_cycle, training_route: route, funding_type: funding_type, **conditions)
    create(:funding_method_subject, funding_method: funding_rule, allocation_subject: allocation_subject)
  end

  def funding_error(funding_type)
    "funding_method '#{funding_type}' is not allowed when training_route is '#{route}' and course_subject_1 is 'chemistry' in academic cycle '2027 to 2028'"
  end

  context "when the bursary is only for a relevant degree" do
    before { create_funding_rule(funding_type: FUNDING_TYPE_ENUMS[:bursary], degree_relevance: "relevant") }

    context "with a relevant degree" do
      it "creates a trainee with a bursary" do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

        expect(response).to be_successful
        expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY)
      end
    end

    context "with an unrelated degree" do
      let(:degree_subject) { "100302" }

      it "does not create a trainee and returns an error" do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly(funding_error("bursary"))
      end
    end
  end

  context "when the bursary is only for an unrelated degree" do
    before { create_funding_rule(funding_type: FUNDING_TYPE_ENUMS[:bursary], degree_relevance: "unrelated") }

    context "with an unrelated degree" do
      let(:degree_subject) { "100302" }

      it "creates a trainee with a bursary" do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

        expect(response).to be_successful
        expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY)
      end
    end

    context "with a relevant degree" do
      it "does not create a trainee and returns an error" do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly(funding_error("bursary"))
      end
    end
  end

  context "when the bursary on an undergraduate route is only for a relevant degree" do
    let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_undergrad] }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::UNDERGRADUATE_BURSARY }

    before { create_funding_rule(funding_type: FUNDING_TYPE_ENUMS[:bursary], degree_relevance: "relevant") }

    context "with a relevant degree" do
      it "does not create a trainee and returns an error" do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly(funding_error("bursary"))
      end
    end
  end

  context "when the grant is only for a disadvantaged school" do
    let(:route) { TRAINING_ROUTE_ENUMS[:school_direct_salaried] }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::GRANT }
    let(:school) { create(:school) }

    before { create_funding_rule(funding_type: FUNDING_TYPE_ENUMS[:grant], school_disadvantage: "disadvantaged") }

    context "with a school on the list" do
      let(:employing_school_urn) { school.urn }

      before { create(:funding_school_designation, academic_cycle:, school:) }

      it "creates a trainee with a grant" do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

        expect(response).to be_successful
        expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::GRANT)
      end
    end

    context "with a school not on the list" do
      let(:employing_school_urn) { school.urn }

      it "does not create a trainee and returns an error" do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly(funding_error("grant"))
      end
    end

    context "without a school" do
      it "creates a trainee with a grant" do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

        expect(response).to be_successful
        expect(response.parsed_body[:data][:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::GRANT)
      end
    end
  end
end
