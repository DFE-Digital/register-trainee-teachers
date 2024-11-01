# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V01::TraineeSerializer do
  let(:trainee) { create(:trainee, :with_lead_partner_scitt, :with_hesa_trainee_detail, :with_diversity_information, :in_progress, :with_placements, :with_french_nationality) }
  let(:json) { described_class.new(trainee).as_hash }

  describe "serialization" do
    let(:fields) do
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
        itt_start_date
        outcome_date
        itt_end_date
        trn
        submitted_for_trn_at
        withdraw_date
        withdraw_reasons_dfe_details
        withdraw_reasons_details
        withdraw_reasons
        defer_date
        recommended_for_award_at
        trainee_start_date
        reinstate_date
        course_min_age
        course_max_age
        course_subject_one
        course_subject_two
        course_subject_three
        awarded_at
        training_initiative
        study_mode
        ebacc
        region
        course_education_phase
        course_uuid
        lead_partner_not_applicable
        employing_school_not_applicable
        submission_ready
        commencement_status
        discarded_at
        additional_dttp_data
        hesa_updated_at
        record_source
        iqts_country
        hesa_editable
        slug_sent_to_dqt_at
        placement_detail
        ukprn
        course_qualification
        course_title
        course_level
        course_study_mode
        course_itt_start_date
        course_age_range
        expected_end_date
        employing_school_urn
        lead_partner_urn
        lead_partner_ukprn
        fund_code
        course_year
        itt_aim
        ni_number
        pg_apprenticeship_start_date
        previous_last_name
        hesa_disabilities
        additional_training_initiative
        nationality
        placements
        degrees
        disability1
        application_id
        ethnic_background
        additional_ethnic_background
        created_from_dttp
        created_from_hesa
        bursary_level
        funding_method
        itt_qualification_aim
        state
      ]
    end

    it "matches the fields" do
      expect(json.keys).to match_array(fields)
    end

    it "includes the correct disability values" do
      expect(json["disability1"]).not_to be_nil
      expect(json["disability1"]).to eq(trainee.hesa_trainee_detail.hesa_disabilities["disability1"])
    end

    describe "placements" do
      let(:placements) do
        trainee.placements.map { |placement| Api::V01::PlacementSerializer.new(placement).as_hash.with_indifferent_access }
      end

      it "serializes with Api::V01::PlacementSerializer" do
        expect(json[:placements]).to eq(placements)
      end
    end

    describe "degrees" do
      let(:degrees) do
        trainee.degrees.map { |degree| Api::V01::DegreeSerializer.new(degree).as_hash.with_indifferent_access }
      end

      it "serializes with Api::V01::DegreeSerializer" do
        expect(json[:degrees]).to eq(degrees)
      end
    end

    describe "HESA trainee details" do
      let(:hesa_trainee_detail) do
        Api::V01::HesaTraineeDetailSerializer.new(trainee.hesa_trainee_detail).as_hash.with_indifferent_access
      end

      it "serializes with Api::V01::HesaTraineeDetailSerializer" do
        expect(trainee.hesa_trainee_detail.attributes.except(*Api::V01::HesaTraineeDetailSerializer::EXCLUDED_ATTRIBUTES)).to eq(hesa_trainee_detail)
      end
    end

    describe "nationality" do
      it "serializes nationality to HESA code" do
        expect(json[:nationality]).to eq("FR")
      end
    end

    describe "lead partner attributes" do
      it "serializes the urn correctly" do
        expect(json[:lead_partner_urn]).not_to be_nil
        expect(json[:lead_partner_urn]).to eq(trainee.lead_partner.urn)
      end

      it "serializes the ukprn correctly" do
        expect(json[:lead_partner_ukprn]).not_to be_nil
        expect(json[:lead_partner_ukprn]).to eq(trainee.lead_partner.ukprn)
      end
    end
  end
end
