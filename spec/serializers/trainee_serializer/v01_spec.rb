# frozen_string_literal: true

require "rails_helper"

RSpec.describe TraineeSerializer::V01 do
  let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :in_progress, :with_placements) }
  let(:json) { described_class.new(trainee).as_hash.with_indifferent_access }

  describe "serialization" do
    it "includes all the expected fields" do
      %w[
        trainee_id
        provider_trainee_id
        hesa_id
        first_names
        last_name
        date_of_birth
        created_at
        updated_at
        email
        middle_names
        training_route
        sex
        diversity_disclosure
        ethnic_group
        ethnicity
        disability_disclosure
        course_subject_one
        itt_start_date
        outcome_date
        itt_end_date
        trn
        submitted_for_trn_at
        withdraw_date
        withdraw_reasons_details
        defer_date
        recommended_for_award_at
        trainee_start_date
        reinstate_date
        course_min_age
        course_max_age
        course_subject_two
        course_subject_three
        awarded_at
        applying_for_bursary
        training_initiative
        bursary_tier
        study_mode
        ebacc
        region
        course_education_phase
        applying_for_scholarship
        applying_for_grant
        course_uuid
        lead_school_not_applicable
        employing_school_not_applicable
        submission_ready
        commencement_status
        discarded_at
        created_from_dttp
        additional_dttp_data
        created_from_hesa
        hesa_updated_at
        record_source
        iqts_country
        hesa_editable
        withdraw_reasons_dfe_details
        slug_sent_to_dqt_at
        placement_detail
        ukprn
        course_qualification
        course_title
        course_level
        course_itt_subject
        course_study_mode
        course_itt_start_date
        course_age_range
        expected_end_date
        employing_school_urn
        lead_partner_urn_ukprn
        fund_code
        course_year
        itt_aim
        ni_number
        postgrad_apprenticeship_start_date
        previous_last_name
        hesa_disabilities
        additional_training_initiative
        nationality
        placements
        degrees
      ].each do |field|
        expect(json.keys).to include(field)
      end
    end

    it "does not include excluded fields" do
      %w[
        id
        slug
        progress
        provider_id
        dttp_id
        placement_assignment_dttp_id
        dttp_update_sha
        dormancy_dttp_id
        lead_school_id
        employing_school_id
        course_allocation_subject_id
        start_academic_cycle_id
        end_academic_cycle_id
        hesa_trn_submission_id
        application_choice_id
        apply_application_id
      ].each do |field|
        expect(json.keys).not_to include(field)
      end
    end

    describe "placements" do
      let(:placements) do
        trainee.placements.map { |placement| PlacementSerializer::V01.new(placement).as_hash.with_indifferent_access }
      end

      it "serializes with PlacementSerializer::V01" do
        expect(json[:placements]).to eq(placements)
      end
    end

    describe "degrees" do
      let(:degrees) do
        trainee.degrees.map { |degree| DegreeSerializer::V01.new(degree).as_hash.with_indifferent_access }
      end

      it "serializes with DegreeSerializer::V01" do
        expect(json[:degrees]).to eq(degrees)
      end
    end
  end
end
