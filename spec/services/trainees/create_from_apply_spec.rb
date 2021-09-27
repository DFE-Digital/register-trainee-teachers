# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromApply do
    let(:candidate_attributes) { {} }
    let(:application_data) { ApiStubs::ApplyApi.application(candidate_attributes: candidate_attributes) }
    let(:apply_application) { create(:apply_application, application: application_data) }
    let(:candidate_info) { ApiStubs::ApplyApi.candidate_info.as_json }
    let(:contact_details) { ApiStubs::ApplyApi.contact_details.as_json }
    let(:non_uk_contact_details) { ApiStubs::ApplyApi.non_uk_contact_details.as_json }
    let(:course_info) { ApiStubs::ApplyApi.course.as_json }
    let(:trainee) { create_trainee_from_apply }
    let(:subject_names) { [] }
    let(:course_code) { course_info["course_code"] }

    let!(:course) do
      create(
        :course_with_subjects,
        code: course_code,
        accredited_body_code: apply_application.accredited_body_code,
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
        gender: candidate_info["gender"],
        ethnic_group: "not_provided_ethnic_group",
        ethnic_background: candidate_info["ethnic_background"],
        diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
        email: contact_details["email"],
        training_route: course.route,
        course_code: course.code,
        course_min_age: course.min_age,
        course_max_age: course.max_age,
        study_mode: "full_time",
      }
    end

    let(:uk_address_attributes) do
      {
        address_line_one: contact_details["address_line1"],
        address_line_two: contact_details["address_line2"],
        town_city: contact_details["address_line3"],
        postcode: contact_details["postcode"],
        locale_code: "uk",
      }
    end

    let(:non_uk_address_attributes) do
      {
        international_address: non_uk_contact_details["address_line1"],
        locale_code: "non_uk",
      }
    end

    subject(:create_trainee_from_apply) { described_class.call(application: apply_application) }

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
      before { create(:trainee, trainee_attributes) }

      it "marks the application as a duplicate" do
        expect {
          create_trainee_from_apply
        }.to change(apply_application, :state).to("non_importable_duplicate")
      end
    end

    context "course doesn't exist" do
      let(:course_code) { "ABC" }

      it "raises a MissingCourseError" do
        expect {
          create_trainee_from_apply
        }.to raise_error described_class::MissingCourseError
      end
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

    context "with a uk address" do
      it { is_expected.to have_attributes(uk_address_attributes) }
    end

    context "with a non-uk address" do
      let(:apply_application) { create(:apply_application, application: ApiStubs::ApplyApi.non_uk_application.to_json) }

      it { is_expected.to have_attributes(non_uk_address_attributes) }
    end

    it "does not capture to sentry" do
      expect(Sentry).not_to receive(:capture_message)
      create_trainee_from_apply
    end

    context "disabilities" do
      context "when the application is diversity disclosed with disabilities" do
        before do
          Disability.create!(Diversities::SEED_DISABILITIES.map(&:to_h))
        end

        it "adds the trianee's disabilities" do
          expect(trainee.disabilities.map(&:name)).to match_array(["Blind", "Long-standing illness"])
        end

        it "sets the diversity disclosure to disclosed" do
          expect(trainee).to be_diversity_disclosed
        end

        it "sets the disability disclosure to provided" do
          expect(trainee).to be_disabled
        end
      end

      context "when the application is diversity and disability disclosed with no disabilities" do
        let(:application_data) do
          ApiStubs::ApplyApi.application(
            candidate_attributes: {
              disabilities: [],
            },
          )
        end

        it "sets the diversity disclosure to disclosed" do
          expect(trainee).to be_diversity_disclosed
        end

        it "sets the disability disclosure to not disabled" do
          expect(trainee).to be_no_disability
        end
      end
    end

    context "when the application is diversity disclosed with no disability information" do
      let(:application_data) do
        ApiStubs::ApplyApi.application(
          candidate_attributes: {
            disability_disclosure: nil,
            disabilities: [],
          },
        )
      end

      it "sets the diversity disclosure to disclosed" do
        expect(trainee).to be_diversity_disclosed
      end

      it "sets the disability disclosure to not provided" do
        expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided])
      end
    end

    context "when nationalities exist" do
      before do
        Nationality.create!(Dttp::CodeSets::Nationalities::MAPPING.keys.map { |key| { name: key } })
      end

      it "adds the trainee's nationalities" do
        expect(trainee.nationalities.map(&:name)).to match_array(%w[british tristanian])
      end

      context "when the trainee's nationalities is unrecognised" do
        before do
          stub_const("ApplyApi::CodeSets::Nationalities::MAPPING", {
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

    context "ethnic background does not match any known ethnic backgrounds" do
      let(:candidate_attributes) { { ethnic_background: "Mixed European" } }

      before { create_trainee_from_apply }

      it "sets ethnic_background attribute to 'Another ethnic background'" do
        expect(trainee.reload.ethnic_background).to eq(Diversities::ANOTHER_ETHNIC_BACKGROUND)
      end

      it "uses the trainee's additional_ethnic_background attribute to store the value from Apply" do
        expect(trainee.reload.additional_ethnic_background).to eq("Mixed European")
      end
    end
  end
end
