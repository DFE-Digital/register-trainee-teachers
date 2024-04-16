# frozen_string_literal: true

require "rails_helper"

describe "Updating a newly created trainee", feature_register_api: true do
  let(:token) { "trainee_token" }
  let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
  let!(:nationality) { create(:nationality, :british) }

  let!(:course_allocation_subject) do
    create(:subject_specialism, name: CourseSubjects::BIOLOGY).allocation_subject
  end
  let(:headers) { { Authorization: token } }

  let(:params_for_create) do
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

  context "when creating a new trainee with valid params" do
    before do
      allow(Api::MapHesaAttributes::V01).to receive(:call).and_call_original
      allow(Trainees::MapFundingFromDttpEntityId).to receive(:call).and_call_original

      post "/api/v0.1/trainees", params: params_for_create, headers: headers
    end

    let(:slug) { response.parsed_body["trainee_id"] }
    let(:trainee) { Trainee.last.reload }

    it "creates a trainee" do
      expect(response).to have_http_status(:created)
      expect(Trainee.count).to eq(1)

      expect(trainee.state).to eq("submitted_for_trn")
      expect(trainee.slug).to eq(slug)
    end

    context "when updating a newly created trainee with valid params" do
      let(:params_for_update) { { data: { first_names: "Alice" } } }

      it "updates the trainee" do
        put(
          "/api/v0.1/trainees/#{slug}",
          params: params_for_update,
          headers: headers,
        )
        expect(response).to have_http_status(:ok)
        expect(trainee.first_names).to eq("Alice")
        expect(response.parsed_body[:data]["trainee_id"]).to eq(slug)
      end
    end
  end
end
