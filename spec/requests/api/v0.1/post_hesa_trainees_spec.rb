# frozen_string_literal: true

require "rails_helper"

describe "`POST /api/v0.1/trainees` endpoint" do
  let(:token) { "trainee_token" }
  let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
  let!(:nationality) { create(:nationality, :british) }

  let!(:course_allocation_subject) do
    create(:subject_specialism, name: CourseSubjects::BIOLOGY).allocation_subject
  end

  let(:params) { { data: } }

  let(:data) do
    {
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
      disability1: "58",
      disability2: "57",
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
      provider_trainee_id: "99157234/2/01",
    }
  end

  context "when the request is valid", feature_register_api: true do
    before do
      allow(Api::MapHesaAttributes::V01).to receive(:call).and_call_original
      allow(Trainees::MapFundingFromDttpEntityId).to receive(:call).and_call_original

      create(:disability, :blind)
      create(:disability, :deaf)

      post "/api/v0.1/trainees", params: params, headers: { Authorization: token }
    end

    it "creates a trainee" do
      expect(response.parsed_body["first_names"]).to eq("John")
    end

    it "sets the correct state" do
      expect(Trainee.last.state).to eq("submitted_for_trn")
    end

    it "sets the correct disabilities" do
      expect(response.parsed_body["disability_disclosure"]).to eq("disabled")
      expect(response.parsed_body["disability1"]).to eq("58")
      expect(response.parsed_body["disability2"]).to eq("57")

      trainee_id = response.parsed_body["trainee_id"]
      trainee = Trainee.find_by(slug: trainee_id)
      expect(trainee.disabilities.count).to eq(2)
      expect(trainee.disabilities.map(&:name)).to contain_exactly("Blind", "Deaf")
    end

    it "sets the correct funding attributes" do
      expect(Trainees::MapFundingFromDttpEntityId).to have_received(:call).once
      expect(Trainee.last.applying_for_scholarship).to be(true)
      expect(Trainee.last.applying_for_bursary).to be(false)
      expect(Trainee.last.applying_for_grant).to be(false)
      expect(response.parsed_body["fund_code"]).to eq("7")
      expect(response.parsed_body["bursary_level"]).to eq("4")
      expect(response.parsed_body["applying_for_scholarship"]).to be_nil
      expect(response.parsed_body["applying_for_bursary"]).to be_nil
      expect(response.parsed_body["applying_for_grant"]).to be_nil
    end

    it "sets the correct school attributes" do
      expect(response.parsed_body["lead_school_not_applicable"]).to be(false)
      expect(response.parsed_body["lead_school"]).to be_nil
      expect(response.parsed_body["employing_school_not_applicable"]).to be(false)
      expect(response.parsed_body["employing_school"]).to be_nil
    end

    it "creates the degrees if provided in the request body" do
      degree_attributes = response.parsed_body["degrees"]&.first

      expect(degree_attributes["subject"]).to eq("100485")
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

    it "sets the provider_trainee_id" do
      expect(Trainee.last.provider_trainee_id).to eq("99157234/2/01")
    end
  end

  context "when the trainee record is invalid", feature_register_api: true do
    before do
      post "/api/v0.1/trainees", params: params, headers: { Authorization: token }
    end

    let(:params) { { data: { email: "Doe" } } }

    it "returns status code 422" do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns a validation failure message" do
      expect(response.parsed_body["errors"]).to contain_exactly("First names can't be blank", "Last name can't be blank", "Date of birth can't be blank", "Sex can't be blank", "Training route can't be blank", "Itt start date can't be blank", "Itt end date can't be blank", "Course subject one can't be blank", "Study mode can't be blank", "Email Enter an email address in the correct format, like name@example.com", "Itt aim can't be blank", "Itt qualification aim can't be blank", "Course year can't be blank", "Course age range can't be blank", "Fund code can't be blank", "Funding method can't be blank", "Hesa can't be blank")
    end

    context "date of birth is in the future" do
      let(:params) { { data: data.merge({ date_of_birth: "2990-01-01" }) } }

      it "returns a validation failure message" do
        expect(response.parsed_body["errors"]).to include({ personal_details: { date_of_birth: ["Enter a date of birth that is in the past, for example 31 3 1980"] } })
      end
    end
  end

  context "when a placement is invalid", feature_register_api: true do
    before do
      params[:data][:placements_attributes] = [{ not_an_attribute: "invalid" }]
      post "/api/v0.1/trainees", params: params, headers: { Authorization: token }
    end

    it "return status code 422 with a meaningful error message" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["message"]).to include("Validation failed: 1 error prohibited this trainee from being saved")
      expect(response.parsed_body["errors"]).to include("Placements name can't be blank")
    end
  end

  context "when a degree is invalid", feature_register_api: true do
    before do
      params[:data][:degrees_attributes].first[:graduation_date] = "3000-01-01"
      post "/api/v0.1/trainees", params: params, headers: { Authorization: token }
    end

    it "return status code 422 with a meaningful error message" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["message"]).to include("Validation failed: 2 errors prohibited this trainee from being saved")
      expect(response.parsed_body["errors"]).to include("Degrees graduation year Enter a graduation year that is in the past, for example 2014")
      expect(response.parsed_body["errors"]).to include("Degrees graduation year Enter a valid graduation year")
    end
  end
end
