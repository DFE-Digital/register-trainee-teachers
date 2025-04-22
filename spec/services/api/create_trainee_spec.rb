# frozen_string_literal: true

require "rails_helper"

describe Api::CreateTrainee do
  let(:current_provider) { create(:provider) }
  let(:degree_attributes) { [] }
  let(:valid_attributes) do
    {
      first_names: "Spencer",
      middle_names: nil,
      last_name: "Murphy",
      date_of_birth: "1967-12-06",
      email: "Spencer.Murphy@example.com",
      course_education_phase: "secondary",
      trainee_start_date: "2024-10-01",
      sex: 0,
      training_route: "provider_led_undergrad",
      itt_start_date: "2024-10-01",
      itt_end_date: "2025-07-06",
      diversity_disclosure: "diversity_not_disclosed",
      ethnicity: nil,
      disability_disclosure: "disability_not_provided",
      course_subject_one: "geography",
      course_subject_two: nil,
      course_subject_three: nil,
      course_allocation_subject_id: nil,
      study_mode: "part_time",
      application_choice_id: nil,
      progress: {
        personal_details: true,
        contact_details: true,
        diversity: true,
        course_details: true,
        training_details: true,
        trainee_start_status: true,
        trainee_data: true,
        schools: true,
        funding: true,
        iqts_country: true,
      },
      training_initiative: "no_initiative",
      hesa_id: "7572897115906",
      provider_trainee_id: "24/25-1",
      applying_for_bursary: false,
      applying_for_grant: false,
      applying_for_scholarship: true,
      bursary_tier: nil,
      nationality: "british",
      lead_partner_id: nil,
      lead_partner_not_applicable: true,
      employing_school_id: nil,
      employing_school_not_applicable: true,
      ethnic_group: "not_provided_ethnic_group",
      ethnic_background: "Not provided",
      course_min_age: 11,
      course_max_age: 19,
      placements_attributes: [],
      degrees_attributes: degree_attributes,
      course_study_mode: "64",
      course_year: "2024",
      ni_number: nil,
      pg_apprenticeship_start_date: "2024-08-05",
      previous_last_name: "Heidenreich",
      hesa_disabilities: {},
      additional_training_initiative: nil,
      itt_aim: "201",
      itt_qualification_aim: "004",
      course_age_range: "13919",
      fund_code: "2",
      funding_method: "4",
      trainee_disabilities_attributes: [],
      record_source: "api",
    }
  end
  let(:trainee_attributes) { Api::V10Pre::TraineeAttributes.new(valid_attributes) }
  let(:version) { Settings.api.current_version }

  subject(:result) do
    described_class.call(
      current_provider:,
      trainee_attributes:,
      version:,
    )
  end

  describe "complex validation errors" do
    def result_errors(errors = result[:json][:errors])
      values = errors.respond_to?(:values) ? errors.values : errors
      values.map do |error|
        if error.is_a?(Hash)
          result_errors(error)
        else
          error
        end
      end.flatten
    end

    describe "the trainee start date is too old" do
      before do
        trainee_attributes.trainee_start_date = "2012-10-01"
      end

      it "API outputs the correct error message" do
        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result_errors).to include("trainee_start_date Cannot be more than 10 years in the past")
      end
    end

    describe "the ITT start date is for a different academic year than the selected course" do
      before do
        trainee_attributes.itt_start_date = "2022-10-01"
        trainee_attributes.itt_end_date = "2023-07-06"
      end

      it "API outputs the correct error message" do
        pending "This doesn't fire for creating a trainee via the API"
        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result_errors).to include("The ITT start date is for a different academic year than the selected course. Enter a valid start date or choose a different year.")
      end
    end

    describe "the expected end date must be after the start date" do
      before do
        trainee_attributes.itt_start_date = Date.current
        trainee_attributes.itt_end_date = Date.current - 1.day
      end

      it "API outputs the correct error message" do
        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result_errors).to include("The Expected end date must be after the start date")
      end
    end

    describe "course subject two must be unique" do
      before do
        trainee_attributes.course_subject_one = "geography"
        trainee_attributes.course_subject_two = "geography"
      end

      it "API outputs the correct error message" do
        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result_errors).to include("Enter a different second subject")
      end
    end

    describe "course subject three must be unique" do
      before do
        trainee_attributes.course_subject_one = "geography"
        trainee_attributes.course_subject_two = "history"
        trainee_attributes.course_subject_three = "geography"
      end

      it "API outputs the correct error message" do
        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result_errors).to include("Enter a different third subject")
      end
    end

    describe "provider_trainee_id must be unique" do
      before do
        create(:trainee, provider_trainee_id: "123456", provider: current_provider)
        trainee_attributes.provider_trainee_id = "123456"
      end

      it "API outputs the correct error message" do
        pending("This validation seems to be skipped for API/CSV uploads")
        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result_errors).to include("The provider trainee ID has already been taken")
      end
    end

    describe "qualification aim is mandatory if itt_aim is 202" do
      before do
        trainee_attributes.hesa_trainee_detail_attributes = Api::V01::HesaTraineeDetailAttributes.new(
          itt_aim: "202",
          itt_qualification_aim: nil,
        )
      end

      it "API outputs the correct error message" do
        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result_errors).to include("Itt qualification aim can't be blank")
      end
    end

    describe "study_mode is mandatory for training route assessment_only" do
      before do
        trainee_attributes.study_mode = nil
        trainee_attributes.training_route = :assessment_only
      end

      it "API outputs the correct error message" do
        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result_errors).to include("study_mode can't be blank")
      end
    end

    describe "lead partner section is not valid for this trainee" do
      before do
        trainee_attributes.training_route = "teacher_degree_apprenticeship"
        trainee_attributes.lead_partner_id = "1234"
        trainee_attributes.lead_partner_not_applicable = false
      end

      it "API outputs the correct error message" do
        pending("This validation seems to be skipped for API/CSV uploads")
        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result_errors).to include("The lead partner section is not valid for this trainee")
      end
    end

    describe "training_intiative is missing" do
      before do
        trainee_attributes.training_initiative = nil
      end

      it "API can save a trainee without `training_initiative`" do
        expect(result[:status]).to eq(:created)
      end
    end

    describe "UK degrees missing" do
      let(:degree_attributes) { [] }

      before do
        trainee_attributes.training_route = "provider_led_postgrad"
      end

      it "API outputs the correct error message for missing grade" do
        expect(result[:status]).to eq(:unprocessable_entity)

        expect(result_errors).to include("Add at least one degree")
      end
    end

    describe "UK degrees" do
      let(:degree_attributes) do
        [
          {
            country: "XF",
            locale_code: "uk",
          },
        ]
      end

      it "API outputs the correct error message for missing grade" do
        expect(result[:status]).to eq(:unprocessable_entity)

        expect(result_errors).to include("degrees_attributes grade can't be blank")
      end

      it "API outputs the correct error message for missing institution" do
        expect(result[:status]).to eq(:unprocessable_entity)

        expect(result_errors).to include("degrees_attributes institution can't be blank")
      end

      it "API outputs the correct error message for missing uk_degree" do
        expect(result[:status]).to eq(:unprocessable_entity)

        expect(result_errors).to include("degrees_attributes uk_degree can't be blank")
      end

      it "API outputs the correct error message for missing graduation year" do
        expect(result[:status]).to eq(:unprocessable_entity)

        expect(result_errors).to include("degrees_attributes graduation_year can't be blank")
      end

      it "API outputs the correct error message for missing subject" do
        expect(result[:status]).to eq(:unprocessable_entity)

        expect(result_errors).to include("degrees_attributes subject can't be blank")
      end
    end

    describe "non-UK degrees" do
      let(:degree_attributes) do
        [
          {
            locale_code: "non_uk",
          },
        ]
      end

      it "API outputs the correct error message for missing country" do
        expect(result[:status]).to eq(:unprocessable_entity)

        expect(result_errors).to include("degrees_attributes country can't be blank")
      end

      it "API outputs the correct error message for non_uk_degree" do
        expect(result[:status]).to eq(:unprocessable_entity)

        expect(result_errors).to include("degrees_attributes non_uk_degree can't be blank")
      end

      it "API outputs the correct error message for missing graduation year" do
        expect(result[:status]).to eq(:unprocessable_entity)

        expect(result_errors).to include("degrees_attributes graduation_year can't be blank")
      end

      it "API outputs the correct error message for missing subject" do
        expect(result[:status]).to eq(:unprocessable_entity)

        expect(result_errors).to include("degrees_attributes subject can't be blank")
      end
    end
  end
end
