# frozen_string_literal: true

require "rails_helper"

describe "Trainees API" do
  let!(:nationality) { create(:nationality, :british) }
  let(:academic_cycle) { create(:academic_cycle, :current) }
  let(:provider) { trainee.provider }
  let(:token) { AuthenticationToken.create_with_random_token(provider: provider, name: "test token", created_by: provider.users.first).token }

  describe "`POST /api/v0.1/trainees` endpoint" do
    let(:valid_attributes) do
      {
        data: {
          first_names: trainee.first_names,
          middle_names: trainee.middle_names,
          last_name: trainee.last_name,
          date_of_birth: trainee.date_of_birth.iso8601,
          sex: Hesa::CodeSets::Sexes::MAPPING.invert[Trainee.sexes[:male]],
          email: trainee.email,
          trn: "123456",
          training_route: Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]],
          itt_start_date: trainee.itt_start_date,
          itt_end_date: trainee.itt_end_date,
          diversity_disclosure: "diversity_disclosed",
          course_subject_one: Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::BIOLOGY],
          study_mode: Hesa::CodeSets::StudyModes::MAPPING.invert[TRAINEE_STUDY_MODE_ENUMS["full_time"]],
          nationality: "GB",
          itt_aim: "202",
          itt_qualification_aim: "001",
          course_year: "2012",
          course_age_range: "13915",
          fund_code: "7",
          funding_method: "4",
          hesa_id: "0310261553101",
        },
      }
    end

    context "when the itt_start_date is in the AcademicCycle#start_date year" do
      let!(:trainee) do
        create(
          :trainee,
          :male,
          :provider_led_undergrad,
          :in_progress,
          itt_start_date: academic_cycle.start_date,
          course_subject_one: CourseSubjects::BIOLOGY,
        )
      end

      it "returns status code 409 (conflict) with the potential duplicates and does not create a trainee record" do
        Timecop.travel trainee.itt_start_date do
          expect {
            post "/api/v0.1/trainees", params: valid_attributes.to_json, headers: { Authorization: token, **json_headers }
          }.not_to change { Trainee.count }

          expect(response).to have_http_status(:conflict)

          expect(response.parsed_body[:errors]).to contain_exactly(
            error: "Conflict",
            message: "This trainee is already in Register",
          )
          expect(response.parsed_body[:data].count).to be(1)
        end
      end
    end

    context "when the itt_start_date is in the AcademicCycle#end_date year" do
      let!(:trainee) do
        create(
          :trainee,
          :male,
          :provider_led_undergrad,
          :in_progress,
          itt_start_date: academic_cycle.end_date.beginning_of_year,
          course_subject_one: CourseSubjects::BIOLOGY,
        )
      end

      it "returns status code 409 (conflict) with the potential duplicates and does not create a trainee record" do
        Timecop.travel trainee.itt_start_date do
          expect {
            post "/api/v0.1/trainees", params: valid_attributes.to_json, headers: { Authorization: token, **json_headers }
          }.not_to change { Trainee.count }

          expect(response).to have_http_status(:conflict)
          expect(response.parsed_body[:errors]).to contain_exactly(
            error: "Conflict",
            message: "This trainee is already in Register",
          )
          expect(response.parsed_body[:data].count).to be(1)
        end
      end
    end
  end
end
