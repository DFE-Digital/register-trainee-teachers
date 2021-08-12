# frozen_string_literal: true

require "rails_helper"

module Exports
  describe TraineeSearchData do
    let(:trainee) do
      create(
        :trainee,
        :with_degree,
        :with_course_details,
        :submitted_for_trn,
        :trn_received,
        :recommended_for_award,
        :awarded,
        :with_tiered_bursary,
        :with_lead_school,
        :with_employing_school,
        gender: "male",
        nationalities: [build(:nationality, name: "British")],
        diversity_disclosure: "diversity_disclosed",
        ethnic_group: "asian_ethnic_group",
        disability_disclosure: "disabled",
        disabilities: [build(:disability, name: "Blind")],
        training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
        training_initiative: "transition_to_teach",
        applying_for_bursary: true,
        international_address: "Test addr",
      )
    end

    subject { described_class.new([trainee]) }

    describe "#data" do
      let(:expected_output) do
        degree = trainee.degrees.first
        course = Course.where(code: trainee.course_code).first
        {
          "register_id" => trainee.slug,
          "trainee_url" => "#{Settings.base_url}/trainees/#{trainee.slug}",
          "apply_id" => trainee.apply_application&.apply_id,
          "provider_training_id" => trainee.trainee_id,
          "trn" => trainee.trn,
          "status" => "QTS awarded",
          "academic_year" => nil,
          "updated_at" => trainee.updated_at&.iso8601,
          "record_created_at" => trainee.created_at&.iso8601,
          "submitted_for_trn_at" => trainee.submitted_for_trn_at&.iso8601,
          "provider_name" => trainee.provider&.name,
          "provider_id" => trainee.provider&.code,
          "first_names" => trainee.first_names,
          "middle_names" => trainee.middle_names,
          "last_names" => trainee.last_name,
          "date_of_birth" => trainee.date_of_birth&.iso8601,
          "gender" => "Male",
          "nationalities" => "British",
          "address_line_1" => trainee.address_line_one,
          "address_line_2" => trainee.address_line_two,
          "town_city" => trainee.town_city,
          "postcode" => trainee.postcode,
          "international_address" => trainee.international_address,
          "email_address" => trainee.email,
          "diversity_disclosure" => "TRUE",
          "ethnic_group" => "Asian or Asian British",
          "ethnic_background" => trainee.ethnic_background,
          "ethnic_background_additional" => trainee.additional_ethnic_background,
          "disability_disclosure" => "TRUE",
          "disabilities" => "Blind",
          "number_of_degrees" => trainee.degrees.count,
          "degree_1_uk_or_non_uk" => "UK",
          "degree_1_institution" => degree&.institution,
          "degree_1_country" => degree&.country,
          "degree_1_subject" => degree&.subject,
          "degree_1_type_of_degree" => degree&.uk_degree,
          "degree_1_non_uk_type" => degree&.non_uk_degree,
          "degree_1_grade" => degree&.grade,
          "degree_1_other_grade" => degree&.other_grade,
          "degree_1_graduation_year" => degree&.graduation_year,
          "degrees" => "\"#{['UK', degree&.institution, degree&.country, degree&.subject, degree&.uk_degree, degree&.non_uk_degree, degree&.grade, degree&.other_grade, degree&.graduation_year].map { |d| "\"\"#{d}\"\"" }.join(', ')}\"",
          "course_code" => trainee.course_code,
          "course_name" => course&.name,
          "course_route" => "Assessment only",
          "course_qualification" => course&.qualification,
          "course_qualification_type" => nil,
          "course_level" => course&.level&.capitalize,
          "course_allocation_subject" => nil,
          "course_itt_subject_1" => trainee.course_subject_one,
          "course_itt_subject_2" => trainee.course_subject_two,
          "course_itt_subject_3" => trainee.course_subject_three,
          "course_min_age" => course&.min_age,
          "course_max_age" => course&.max_age,
          "course_study_mode" => nil,
          "course_start_date" => trainee.course_start_date&.iso8601,
          "course_end_date" => trainee.course_end_date&.iso8601,
          "course_duration_in_years" => course&.duration_in_years,
          "course_summary" => course&.summary,
          "commencement_date" => trainee.commencement_date&.iso8601,
          "lead_school_name" => trainee.lead_school&.name,
          "lead_school_urn" => trainee.lead_school&.urn,
          "employing_school_name" => trainee.employing_school&.name,
          "employing_school_urn" => trainee.employing_school&.urn,
          "training_initiative" => "Transition to teach",
          "applying_for_bursary" => trainee.applying_for_bursary.to_s.upcase,
          "bursary_value" => (trainee.bursary_amount if trainee.applying_for_bursary),
          "bursary_tier" => ("Tier #{BURSARY_TIERS[trainee.bursary_tier] + 1}" if trainee.bursary_tier),
          "award_standards_met_date" => trainee.outcome_date&.iso8601,
          "award_awarded_at" => trainee.awarded_at&.iso8601,
          "defer_date" => trainee.defer_date&.iso8601,
          "reinstate_date" => trainee.reinstate_date&.iso8601,
          "withdraw_date" => trainee.withdraw_date&.to_date&.iso8601,
          "withdraw_reason" => trainee.withdraw_reason,
          "additional_withdraw_reason" => trainee.additional_withdraw_reason,
        }
      end

      it "sets the correct headers" do
        expect(subject.data).to include(expected_output.keys.join(","))
      end

      it "sets the correct row values" do
        expect(subject.data).to include(expected_output.values.join(","))
      end

      context "when names contain whitespace or vulnerable characters" do
        before do
          trainee.update!(first_names: "Christophe", middle_names: "Malcolm", last_name: "=SUM(A1&A2)")
        end

        it "adds an apostrophe before vulnerable characters" do
          expect(subject.data).to include("Christophe,Malcolm,'=SUM(A1&A2)")
        end
      end
    end

    describe "#time" do
      let(:time_now_in_zone) { Time.zone.now }

      let(:expected_filename) do
        "#{time_now_in_zone.strftime('%Y-%m-%d_%H-%M_%S')}_Register-trainee-teachers_exported_records.csv"
      end

      before do
        allow(Time).to receive(:now).and_return(time_now_in_zone)
      end

      it "sets the correct filename" do
        expect(subject.filename).to eq(expected_filename)
      end
    end
  end
end
