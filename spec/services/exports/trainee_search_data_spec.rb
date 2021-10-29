# frozen_string_literal: true

require "rails_helper"

module Exports
  describe TraineeSearchData do
    let(:trainee) do
      create(
        :trainee,
        :with_degree,
        :with_primary_course_details,
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
    let(:funding_manager) do
      FundingManager.new(trainee)
    end

    subject { described_class.new([trainee]) }

    describe "#data" do
      let(:expected_output) do
        degree = trainee.degrees.first
        course = Course.find_by(uuid: trainee.course_uuid)
        {
          "register_id" => trainee.slug,
          "trainee_url" => "#{Settings.base_url}/trainees/#{trainee.slug}",
          "apply_id" => trainee.apply_application&.apply_id,
          "provider_trainee_id" => trainee.trainee_id,
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
          "degree_1_awarding_institution" => degree&.institution,
          "degree_1_country" => degree&.country,
          "degree_1_subject" => degree&.subject,
          "degree_1_type_of_degree" => degree&.uk_degree,
          "degree_1_non_uk_type" => degree&.non_uk_degree,
          "degree_1_grade" => degree&.grade,
          "degree_1_other_grade" => degree&.other_grade,
          "degree_1_graduation_year" => degree&.graduation_year,
          "degrees" => "\"#{['UK', degree&.institution, degree&.country, degree&.subject, degree&.uk_degree, degree&.non_uk_degree, degree&.grade, degree&.other_grade, degree&.graduation_year].map { |d| "\"\"#{d}\"\"" }.join(', ')}\"",
          "course_code" => course&.code,
          "course_name" => course&.name,
          "course_route" => "Assessment only",
          "course_qualification" => trainee.award_type,
          "course_education_phase" => trainee.course_education_phase.upcase_first,
          "course_allocation_subject" => nil,
          "course_itt_subject_1" => trainee.course_subject_one,
          "course_itt_subject_2" => trainee.course_subject_two,
          "course_itt_subject_3" => trainee.course_subject_three,
          "course_min_age" => trainee.course_min_age,
          "course_max_age" => trainee.course_max_age,
          "course_study_mode" => trainee.study_mode.humanize,
          "course_start_date" => trainee.course_start_date&.iso8601,
          "course_end_date" => trainee.course_end_date&.iso8601,
          "course_duration_in_years" => trainee.course_duration_in_years,
          "course_summary" => course&.summary,
          "commencement_date" => trainee.commencement_date&.iso8601,
          "lead_school_name" => trainee.lead_school&.name,
          "lead_school_urn" => trainee.lead_school&.urn,
          "employing_school_name" => trainee.employing_school&.name,
          "employing_school_urn" => trainee.employing_school&.urn,
          "training_initiative" => "Transition to Teach",
          "funding_method" => "bursary",
          "funding_value" => (funding_manager.bursary_amount if trainee.applying_for_bursary),
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

    describe "#funding_method" do
      it "returns bursary" do
        trainee = Trainee.new(applying_for_bursary: true)
        expect(subject.send(:funding_method, trainee)).to eq("bursary")
      end

      it "returns scholarship" do
        trainee = Trainee.new(applying_for_scholarship: true)
        expect(subject.send(:funding_method, trainee)).to eq("scholarship")
      end

      it "returns grant" do
        trainee = Trainee.new(applying_for_grant: true)
        expect(subject.send(:funding_method, trainee)).to eq("grant")
      end

      it "returns not funded" do
        trainee = Trainee.new(applying_for_bursary: false)
        expect(subject.send(:funding_method, trainee)).to eq("not funded")

        trainee = Trainee.new(applying_for_scholarship: false)
        expect(subject.send(:funding_method, trainee)).to eq("not funded")

        trainee = Trainee.new(applying_for_grant: false)
        expect(subject.send(:funding_method, trainee)).to eq("not funded")
      end
    end

    describe "#course_summary" do
      it "returns blank" do
        trainee = Trainee.new(study_mode: "full_time")
        course = Course.new(summary: nil)
        expect(subject.send(:course_summary, trainee, course)).to be_nil

        trainee = Trainee.new(study_mode: nil)
        course = Course.new(summary: "PGCE full time")
        expect(subject.send(:course_summary, trainee, course)).to be_nil
      end

      it "returns full time" do
        trainee = Trainee.new(study_mode: "full_time")
        course = Course.new(summary: "PGCE full time")
        expect(subject.send(:course_summary, trainee, course)).to eq("PGCE full time")

        trainee = Trainee.new(study_mode: "full_time")
        course = Course.new(summary: "PGCE part time")
        expect(subject.send(:course_summary, trainee, course)).to eq("PGCE full time")
      end

      it "returns part time" do
        trainee = Trainee.new(study_mode: "part_time")
        course = Course.new(summary: "PGCE with QTS part time")
        expect(subject.send(:course_summary, trainee, course)).to eq("PGCE with QTS part time")

        trainee = Trainee.new(study_mode: "part_time")
        course = Course.new(summary: "PGCE with QTS full time")
        expect(subject.send(:course_summary, trainee, course)).to eq("PGCE with QTS part time")
      end
    end
  end
end
