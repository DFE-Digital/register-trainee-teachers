# frozen_string_literal: true

require "rails_helper"

RSpec.describe TraineeSerializer::V01 do
  let(:trainee) { create(:trainee, :in_progress, :with_placements) }
  let(:json) { described_class.new(trainee).as_hash.with_indifferent_access }

  describe "serialization" do
    it "includes all the expected fields" do
      %w[
        ukprn
        trainee_id
        provider_trainee_id
        apply_application_id
        trn
        first_names
        middle_names
        last_name
        date_of_birth
        sex
        nationality
        email
        training_route
        submitted_for_trn_at
        updated_at
        course_qualification
        course_level
        course_title
        course_itt_subject
        course_education_phase
        course_study_mode
        course_itt_start_date
        course_age_range
        expected_end_date
        employing_school_urn
        lead_partner_urn_ukprn
        trainee_start_date
        training_initiative
        hesa_id
        ethnicity
        ethnicity_background
        other_ethnicity_details
        disability
        other_disability_details
        fund_code
        funding_option
        course_age_range
        course_study_mode
        course_year
        funding_method
        itt_aim
        ni_number
        postgrad_apprenticeship_start_date
        previous_last_name
        hesa_disabilities
        additional_training_initiative
      ].each do |field|
        expect(json.keys).to include(field)
      end
    end

    it "does not include excluded fields" do
      %w[
        id
        slug
      ].each do |field|
        expect(json.keys).not_to include(field)
      end
    end

    excluded_attributes.each do |field|
      it "does not serializes the #{field} field" do
        expect(json).not_to have_key(field)
      end
    end
  end
end
