# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe FindDuplicates do
    let(:candidate_attributes) { {} }
    let(:course_attributes) { {} }
    let(:application_record) { create(:apply_application, application: application_data) }
    let(:candidate_info) { ApiStubs::ApplyApi.candidate_info.as_json }
    let(:contact_details) { ApiStubs::ApplyApi.contact_details.as_json }
    let(:course_info) { ApiStubs::ApplyApi.course.as_json }
    let(:subject_names) { [] }
    let(:recruitment_cycle_year) { current_academic_year + 1 }
    let(:course_uuid) { course_info["course_uuid"] }
    let!(:current_academic_cycle) { create(:academic_cycle) }
    let!(:next_academic_cycle) { create(:academic_cycle, next_cycle: true) }
    let!(:after_next_academic_cycle) { create(:academic_cycle, one_after_next_cycle: true) }

    let(:application_data) do
      JSON.parse(ApiStubs::ApplyApi.application(candidate_attributes: candidate_attributes,
                                                course_attributes: course_attributes.merge(recruitment_cycle_year:)))
    end

    let!(:course) do
      create(
        :course_with_subjects,
        uuid: course_uuid,
        accredited_body_code: application_record.accredited_body_code,
        route: :school_direct_tuition_fee,
        subject_names: subject_names,
      )
    end

    let(:trainee_attributes) do
      {
        trainee_id: nil,
        first_names: candidate_info["first_name"],
        last_name: candidate_info["last_name"],
        date_of_birth: candidate_info["date_of_birth"].to_date,
        sex: candidate_info["gender"],
        ethnic_group: "asian_ethnic_group",
        ethnic_background: candidate_info["ethnic_background"],
        diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
        email: contact_details["email"],
        course_education_phase: course.level,
        training_route: course.route,
        course_uuid: course.uuid,
        course_min_age: course.min_age,
        course_max_age: course.max_age,
        study_mode: "full_time",
        record_source: RecordSources::APPLY,
      }
    end

    let(:duplicate_trainee_attributes) do
      trainee_attributes.merge(
        itt_start_date: Date.new(recruitment_cycle_year, 9, 1),
      )
    end

    subject(:duplicate_trainees) { described_class.call(application_record:) }

    context "trainee already exists" do
      before { create(:trainee, duplicate_trainee_attributes) }

      it "returns a match" do
        expect(duplicate_trainees).to be_present
      end
    end

    context "trainee with match last name and DOB exists but first name and email both differ" do
      before do
        create(
          :trainee,
          duplicate_trainee_attributes.merge(
            first_names: "Bob",
            email: "bob@example.com",
          ),
        )
      end

      it "returns no duplicates" do
        expect(duplicate_trainees).to be_empty
      end
    end

    context "trainee with match last name and DOB exists and first name also matches but email differs" do
      before do
        create(
          :trainee,
          duplicate_trainee_attributes.merge(
            first_names: "Martin",
            email: "mwells@mailinator.COM ",
          ),
        )
      end

      it "returns a match" do
        expect(duplicate_trainees).to be_present
      end
    end

    context "trainee with match last name and DOB exists and first name matches but email and middle names do not" do
      before do
        create(
          :trainee,
          duplicate_trainee_attributes.merge(
            first_names: "Martin Derek Clive",
            email: "mwells@mailinator.COM ",
          ),
        )
      end

      it "returns a match" do
        expect(duplicate_trainees).to be_present
      end
    end

    context "trainee with match last name and DOB exists but first name and email differ only by case/spacing" do
      before do
        create(
          :trainee,
          duplicate_trainee_attributes.merge(
            first_names: " MaRtIn.",
            email: "martin.wells@mailinator.COM ",
          ),
        )
      end

      it "returns a match" do
        expect(duplicate_trainees).to be_present
      end
    end

    context "trainee with matching DOB exists but last name differs" do
      before { create(:trainee, duplicate_trainee_attributes.merge(last_name: "Jones")) }

      it "returns no duplicates" do
        expect(duplicate_trainees).to be_empty
      end
    end

    context "trainee with matching last_name exists but DOB differs" do
      before { create(:trainee, duplicate_trainee_attributes.merge(date_of_birth: "1998-03-19")) }

      it "returns no duplicates" do
        expect(duplicate_trainees).to be_empty
      end
    end

    context "trainee with matching last_name and DOB exists but qualification type differs" do
      before { create(:trainee, duplicate_trainee_attributes.merge(training_route: :early_years_undergrad)) }

      it "returns no duplicates" do
        expect(duplicate_trainees).to be_empty
      end
    end

    context "trainee with matching last_name and DOB exists but recruitment_cycle_year differs" do
      around do |example|
        Timecop.freeze(Date.new(2023, 7, 1)) { example.run }
      end

      before do
        previous_academic_cycle = create(:academic_cycle, previous_cycle: true)
        create(
          :trainee,
          trainee_attributes.merge(
            start_academic_cycle: previous_academic_cycle,
            itt_start_date: previous_academic_cycle.start_date,
          ),
        )
      end

      it "returns no duplicates" do
        expect(duplicate_trainees).to be_empty
      end
    end

    context "trainee already exists but last name only differs by case" do
      before do
        create(
          :trainee,
          duplicate_trainee_attributes.merge(
            last_name: candidate_info["last_name"].downcase,
          ),
        )
      end

      it "returns a match" do
        expect(duplicate_trainees).to be_present
      end
    end
  end
end
