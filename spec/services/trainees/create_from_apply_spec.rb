# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromApply do
    let(:candidate_attributes) { {} }
    let(:course_attributes) { {} }
    let(:apply_application) { create(:apply_application, application: application_data) }
    let(:candidate_info) { ApiStubs::RecruitsApi.candidate_info.as_json }
    let(:contact_details) { ApiStubs::RecruitsApi.contact_details.as_json }
    let(:non_uk_contact_details) { ApiStubs::RecruitsApi.non_uk_contact_details.as_json }
    let(:course_info) { ApiStubs::RecruitsApi.course.as_json }
    let(:trainee) { create_trainee_from_apply }
    let(:subject_names) { [] }
    let(:recruitment_cycle_year) { current_academic_year + 1 }
    let(:course_uuid) { course_info["course_uuid"] }
    let(:duplicates) { [] }
    let!(:current_academic_cycle) { create(:academic_cycle) }
    let!(:next_academic_cycle) { create(:academic_cycle, next_cycle: true) }
    let!(:after_next_academic_cycle) { create(:academic_cycle, one_after_next_cycle: true) }

    let(:application_data) do
      JSON.parse(ApiStubs::RecruitsApi.application(candidate_attributes: candidate_attributes,
                                                   course_attributes: course_attributes.merge(recruitment_cycle_year:)))
    end

    let!(:course) do
      create(
        :course_with_subjects,
        uuid: course_uuid,
        accredited_body_code: apply_application.accredited_body_code,
        route: :school_direct_tuition_fee,
        subject_names: subject_names,
      )
    end

    let(:trainee_attributes) do
      {
        provider_trainee_id: nil,
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
        record_source: Trainee::APPLY_SOURCE,
        application_choice_id: apply_application.apply_id,
      }
    end

    subject(:create_trainee_from_apply) { described_class.call(application: apply_application) }

    before do
      allow(Trainees::FindDuplicatesOfApplyApplication).to receive(:call).and_return(duplicates)
    end

    it "creates a draft trainee" do
      expect {
        create_trainee_from_apply
      }.to change(Trainee.draft, :count).by(1)
    end

    it "marks the application as imported" do
      expect {
        create_trainee_from_apply
      }.to change(apply_application, :state).to("imported")
    end

    context "trainee already exists" do
      let(:duplicates) { [build(:trainee)] }

      it "marks the application as a duplicate" do
        expect {
          create_trainee_from_apply
        }.to change(apply_application, :state).to("non_importable_duplicate")
      end
    end

    context "course doesn't exist" do
      let(:course_uuid) { "c6b9f9f0-f9f9-4f0f-b9e2-f9f9f9f9f9f9" }

      it "raises a MissingCourseError" do
        expect {
          create_trainee_from_apply
        }.to raise_error described_class::MissingCourseError
      end
    end

    context "apply application status is 'pending_conditions'" do
      let(:application_data) do
        JSON.parse(ApiStubs::RecruitsApi.application(candidate_attributes: candidate_attributes,
                                                     course_attributes: course_attributes.merge(recruitment_cycle_year:),
                                                     status: "pending_conditions"))
      end

      it "creates a draft trainee" do
        expect {
          create_trainee_from_apply
        }.to change(Trainee.draft, :count).by(1)
      end

      it "created trainee against the apply_application status as 'pending_conditions'" do
        expect(trainee.apply_application.application.dig("attributes", "status")).to eq("pending_conditions")
      end
    end

    it "created trainee against the apply_application status as 'recruited'" do
      expect(trainee.apply_application.application.dig("attributes", "status")).to eq("recruited")
    end

    it { is_expected.to have_attributes(trainee_attributes) }

    it "associates the created trainee against the apply_application and provider" do
      expect(trainee.apply_application).to eq(apply_application)
      expect(trainee.provider.code).to eq(apply_application.accredited_body_code)
    end

    it "calls the Degrees::CreateFromApply service" do
      expect(::Degrees::CreateFromApply).to receive(:call).and_call_original
      create_trainee_from_apply
    end

    it "does not capture to sentry" do
      expect(Sentry).not_to receive(:capture_message)
      create_trainee_from_apply
    end

    context "course education phase" do
      it { is_expected.to have_attributes(course_education_phase: COURSE_EDUCATION_PHASE_ENUMS[:primary]) }
    end

    context "disabilities" do
      before do
        DfEReference::DisabilitiesQuery.all.each do |reference_data|
          Disability.create!(name: reference_data.name, uuid: reference_data.id)
        end
      end

      context "when the application is diversity disclosed with disabilities" do
        it "adds the trainee's disabilities" do
          disability_names = trainee.disabilities.pluck(:name)

          expect(disability_names).to include("Blindness or a visual impairment not corrected by glasses")
          expect(disability_names).to include("Long-term illness")
        end

        it "sets the diversity disclosure to disclosed" do
          expect(trainee).to be_diversity_disclosed
        end

        it "sets the disability disclosure to provided" do
          expect(trainee).to be_disabled
        end
      end

      context "when the application has an empty list of disabilities_and_health_conditions" do
        let(:candidate_attributes) do
          {
            disabilities_and_health_conditions: [],
          }
        end

        it "sets the disability disclosure to not provided" do
          expect(trainee).to be_disability_not_provided
        end
      end

      context "when the application has a nil value for disabilities_and_health_conditions" do
        let(:candidate_attributes) do
          {
            disabilities_and_health_conditions: nil,
          }
        end

        it "sets the disability disclosure to not provided" do
          expect(trainee).to be_disability_not_provided
        end
      end

      context "when the application has no disabilities" do
        let(:candidate_attributes) do
          {
            disabilities_and_health_conditions: [
              {
                uuid: DfEReference::DisabilitiesQuery::NO_DISABILITY_UUID,
              },
            ],
          }
        end

        it "sets the disability disclosure to not disabled" do
          expect(trainee).to be_no_disability
        end
      end

      context "when the application has no disabilities and a disability" do
        let(:candidate_attributes) do
          {
            disabilities_and_health_conditions: [
              {
                uuid: DfEReference::DisabilitiesQuery::NO_DISABILITY_UUID,
              },
              {
                name: "Blindness or a visual impairment not corrected by glasses",
                uuid: "a31b75e7-659d-4547-9654-5fc1015ad2a5",
              },
            ],
          }
        end

        it "sets the disability disclosure to not disabled" do
          expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability])
        end
      end

      context "when the application is diversity disclosed with no disability information" do
        let(:candidate_attributes) do
          {
            disabilities_and_health_conditions: [
              {
                uuid: DfEReference::DisabilitiesQuery::PREFER_NOT_TO_SAY_UUID,
              },
            ],
          }
        end

        it "sets the disability disclosure to not provided" do
          expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided])
        end
      end

      context "when the application has a custom disability" do
        let(:custom_disability) { "Long term pain" }
        let(:generic_disability) do
          DfEReference::DisabilitiesQuery.find_disability(id: DfEReference::DisabilitiesQuery::OTHER_DISABILITY_UUID)
        end

        let(:candidate_attributes) do
          {
            disabilities_and_health_conditions: [
              generic_disability.to_h.merge(text: custom_disability, uuid: generic_disability.id),
            ],
          }
        end

        it "sets the disability as generic" do
          expect(trainee.disabilities.pluck(:uuid)).to include(DfEReference::DisabilitiesQuery::OTHER_DISABILITY_UUID)
        end

        it "sets the disability to the custom value" do
          expect(trainee.trainee_disabilities.pluck(:additional_disability)).to include(custom_disability)
        end

        it "sets the disability disclosure to not provided" do
          expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled])
        end
      end
    end

    context "when nationalities exist" do
      before do
        Nationality.create!(CodeSets::Nationalities::MAPPING.keys.map { |key| { name: key } })
      end

      it "adds the trainee's nationalities" do
        expect(trainee.nationalities.map(&:name)).to match_array(%w[british tristanian])
      end

      context "when the trainee's nationalities is unrecognised" do
        before do
          stub_const("RecruitsApi::CodeSets::Nationalities::MAPPING", {
            "AL" => "albanian",
            "GB" => "british",
          })
        end

        it "captures a message to sentry" do
          expect(Sentry).to receive(:capture_message).with("Cannot map nationality from ApplyApplication id: #{apply_application.id}, code: SH")
          create_trainee_from_apply
        end
      end
    end

    context "ethnicity" do
      context "ethnic group is not specified" do
        let(:candidate_attributes) { { ethnic_group: nil } }

        it "sets the ethnic group to not provided" do
          expect(trainee.reload.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
        end

        it "doesn't set any background attributes" do
          expect(trainee.reload.ethnic_background).to be_nil
          expect(trainee.reload.additional_ethnic_background).to be_nil
        end
      end

      context "ethnic group is not provided" do
        let(:candidate_attributes) { { ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided] } }

        it "doesn't set any background attributes" do
          expect(trainee.reload.ethnic_background).to be_nil
          expect(trainee.reload.additional_ethnic_background).to be_nil
        end
      end

      context "ethnic background does not match any known ethnic backgrounds" do
        let(:candidate_attributes) do
          { ethnic_group: "White", ethnic_background: "Mixed European" }
        end

        before { create_trainee_from_apply }

        it "sets ethnic_background attribute to a known generic background" do
          expect(trainee.reload.ethnic_background).to eq(Diversities::ANOTHER_WHITE_BACKGROUND)
        end

        it "uses the trainee's additional_ethnic_background attribute to store the free text value from Apply" do
          expect(trainee.reload.additional_ethnic_background).to eq("Mixed European")
        end
      end

      context "gender" do
        %w[intersex other].each do |option|
          context "when the gender attribute is #{option}" do
            let(:candidate_attributes) { { gender: option.to_s } }

            before { create_trainee_from_apply }

            it "sets the trainee's sex to other" do
              expect(trainee.reload.sex).to eq("other")
            end
          end
        end
      end
    end
  end
end
