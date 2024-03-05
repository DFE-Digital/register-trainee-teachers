# frozen_string_literal: true

require "rails_helper"

describe "`POST /api/v0.1/trainees` endpoint" do
  let(:token) { "trainee_token" }
  let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }

  let(:valid_attributes) do
    {
      data: {
        first_names: "John",
        middle_names: "James",
        last_name: "Doe",
        date_of_birth: "1990-01-01",
        sex: "male",
        email: "john.doe@example.com",
        trn: "123456",
        training_route: "assessment_only",
        itt_start_date: "2022-09-01",
        itt_end_date: "2023-07-01",
        diversity_disclosure: "diversity_disclosed",
        ethnic_group: "white_ethnic_group",
        ethnic_background: "Background 1",
        disability_disclosure: "no_disability",
        course_subject_one: "Maths",
        course_subject_two: "Science",
        course_subject_three: "English",
        study_mode: "full_time",
        application_choice_id: "123",
        placements_attributes: [{ urn: "123456", name: "Placement" }],
        degrees_attributes: [{ country: "UK", grade: "First", subject: "Computer Science", institution: "University of Test", graduation_year: "2012", locale_code: "uk" }],
      },
    }
  end

  context "when the request is valid", feature_register_api: true do
    before do
      post "/api/v0.1/trainees", params: valid_attributes, headers: { Authorization: token }
    end

    it "creates a trainee" do
      expect(response.parsed_body["first_names"]).to eq("John")
    end

    it "creates associated placements" do
      expect(response.parsed_body["placements"].first["urn"]).to eq("123456")
    end

    it "creates associated degrees" do
      expect(response.parsed_body["degrees"].first["country"]).to eq("UK")
    end

    it "returns status code 201" do
      expect(response).to have_http_status(:created)
    end

    it "sets the progress data structure" do
      expect(Trainee.last.progress.personal_details).to be(true)
    end
  end

  context "when the request is invalid", feature_register_api: true do
    before do
      post "/api/v0.1/trainees", params: { data: { last_name: "Doe" } }, headers: { Authorization: token }
    end

    it "returns status code 422" do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns a validation failure message" do
      expect(response.parsed_body["errors"]).to include("First names can't be blank")
    end
  end
end
