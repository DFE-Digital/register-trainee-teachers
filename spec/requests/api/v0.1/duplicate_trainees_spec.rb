# frozen_string_literal: true

require "rails_helper"

describe "Trainees API" do
  let(:academic_cycle) { create(:academic_cycle, :current) }
  let!(:trainee) { create(:trainee, :in_progress, itt_start_date: academic_cycle.start_date) }
  let(:provider) { trainee.provider }
  let(:token) { AuthenticationToken.create_with_random_token(provider:) }

  describe "POST /api/v0.1/trainees" do
    let(:valid_attributes) do
      {
        data: {
          first_names: trainee.first_names,
          middle_names: trainee.middle_names,
          last_name: trainee.last_name,
          date_of_birth: trainee.date_of_birth.iso8601,
          sex: trainee.sex,
          email: trainee.email,
          trn: "123456",
          training_route: trainee.training_route,
          itt_start_date: trainee.itt_start_date,
          itt_end_date: trainee.itt_end_date,
          diversity_disclosure: "diversity_disclosed",
          course_subject_one: trainee.course_subject_one,
          study_mode: trainee.study_mode,
        },
      }
    end

    context "when the request attempts to create a duplicate record", feature_register_api: true do
      it "returns status 409 (conflict) with the potential duplicates and does not create a trainee record" do
        expect { api_post 0.1, :trainees, params: valid_attributes, token: "Bearer #{token}" }.not_to change { Trainee.count }
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body[:data].count).to be(1)
      end
    end
  end
end
