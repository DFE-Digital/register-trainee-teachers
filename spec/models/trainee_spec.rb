# frozen_string_literal: true

require "rails_helper"

describe Trainee do
  context "fields" do
    subject { build(:trainee) }

    it do
      expect(subject).to define_enum_for(:training_route).with_values(
        TRAINING_ROUTE_ENUMS[:assessment_only] => 0,
        TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => 1,
        TRAINING_ROUTE_ENUMS[:early_years_undergrad] => 2,
        TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => 3,
        TRAINING_ROUTE_ENUMS[:school_direct_salaried] => 4,
        TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] => 5,
        TRAINING_ROUTE_ENUMS[:early_years_assessment_only] => 6,
        TRAINING_ROUTE_ENUMS[:early_years_salaried] => 7,
        TRAINING_ROUTE_ENUMS[:early_years_postgrad] => 8,
        TRAINING_ROUTE_ENUMS[:provider_led_undergrad] => 9,
        TRAINING_ROUTE_ENUMS[:opt_in_undergrad] => 10,
        TRAINING_ROUTE_ENUMS[:hpitt_postgrad] => 11,
      )
    end

    it { is_expected.to define_enum_for(:locale_code).with_values(uk: 0, non_uk: 1) }
    it { is_expected.to define_enum_for(:gender).with_values(male: 0, female: 1, other: 2, gender_not_provided: 3) }

    it do
      expect(subject).to define_enum_for(:diversity_disclosure).with_values(
        Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] => 0,
        Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] => 1,
      )
    end

    it do
      expect(subject).to define_enum_for(:disability_disclosure).with_values(
        Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] => 0,
        Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] => 1,
        Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] => 2,
      )
    end

    it do
      expect(subject).to define_enum_for(:training_initiative).with_values(
        ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars] => 0,
        ROUTE_INITIATIVES_ENUMS[:maths_physics_chairs_programme_researchers_in_schools] => 1,
        ROUTE_INITIATIVES_ENUMS[:now_teach] => 2,
        ROUTE_INITIATIVES_ENUMS[:transition_to_teach] => 3,
        ROUTE_INITIATIVES_ENUMS[:no_initiative] => 4,
        ROUTE_INITIATIVES_ENUMS[:troops_to_teachers] => 5,
      )
    end

    it do
      expect(subject).to define_enum_for(:ethnic_group).with_values(
        Diversities::ETHNIC_GROUP_ENUMS[:asian] => 0,
        Diversities::ETHNIC_GROUP_ENUMS[:black] => 1,
        Diversities::ETHNIC_GROUP_ENUMS[:mixed] => 2,
        Diversities::ETHNIC_GROUP_ENUMS[:white] => 3,
        Diversities::ETHNIC_GROUP_ENUMS[:other] => 4,
        Diversities::ETHNIC_GROUP_ENUMS[:not_provided] => 5,
      )
    end

    it do
      expect(subject).to define_enum_for(:bursary_tier).with_values(
        BURSARY_TIER_ENUMS[:tier_one] => 0,
        BURSARY_TIER_ENUMS[:tier_two] => 1,
        BURSARY_TIER_ENUMS[:tier_three] => 2,
      )
    end
  end

  context "scopes" do
    describe "with_award_states" do
      it "returns trainees with the correct training route and state" do
        create(:trainee, :trn_received)
        qts_awarded = create(:trainee, :qts_awarded)
        eyts_recommended = create(:trainee, :eyts_recommended)
        create(:trainee, :eyts_awarded)

        expect(Trainee.with_award_states(:qts_awarded, :eyts_recommended)).to contain_exactly(qts_awarded, eyts_recommended)
      end
    end

    describe ".on_early_years_routes" do
      it "returns trainees with the correct training route and state" do
        create(:trainee, :school_direct_salaried)
        early_years_trainee = create(:trainee, training_route: EARLY_YEARS_TRAINING_ROUTES.values.sample)

        expect(described_class.on_early_years_routes).to contain_exactly(early_years_trainee)
      end
    end

    describe ".with_education_phase" do
      it "returns trainees with the correct training route and state" do
        create(:trainee, :with_primary_education)
        secondary_trainee = create(:trainee, :with_secondary_education)
        early_years_trainee = create(:trainee, training_route: EARLY_YEARS_TRAINING_ROUTES.values.sample)

        expect(described_class.with_education_phase("secondary", "early_years")).to contain_exactly(early_years_trainee, secondary_trainee)
      end
    end

    describe ".with_apply_application" do
      let!(:manual_trainee) { create(:trainee) }
      let!(:apply_trainee) { create(:trainee, :with_apply_application) }

      it "returns trainees from apply" do
        expect(described_class.with_apply_application).to contain_exactly(apply_trainee)
      end
    end

    describe ".with_manual_application" do
      let!(:manual_trainee) { create(:trainee) }
      let!(:apply_trainee) { create(:trainee, :with_apply_application) }

      it "returns trainees from apply" do
        expect(described_class.with_manual_application).to contain_exactly(manual_trainee)
      end
    end
  end

  context "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:apply_application).optional }
    it { is_expected.to have_many(:degrees).dependent(:destroy) }
    it { is_expected.to have_many(:nationalisations).dependent(:destroy).inverse_of(:trainee) }
    it { is_expected.to have_many(:nationalities).through(:nationalisations) }
    it { is_expected.to have_many(:trainee_disabilities).dependent(:destroy).inverse_of(:trainee) }
    it { is_expected.to have_many(:disabilities).through(:trainee_disabilities) }
    it { is_expected.to belong_to(:lead_school).class_name("School").optional }
    it { is_expected.to belong_to(:employing_school).class_name("School").optional }

    describe "#published_course" do
      let(:same_code) { "1TX" }
      let(:provider_a) { create(:provider, :with_courses, course_code: same_code) }
      let!(:provider_b) { create(:provider, :with_courses, course_code: same_code) }

      subject { create(:trainee, provider: provider_a, course_uuid: provider_a.courses.first.uuid).published_course.provider }

      it { is_expected.to eq(provider_a) }
    end
  end

  context "validations" do
    context "training route" do
      let(:provider) { build(:provider, code: TEACH_FIRST_PROVIDER_CODE) }
      let(:training_route) { TRAINING_ROUTE_ENUMS[:hpitt_postgrad] }

      subject { build(:trainee, provider: provider, training_route: training_route) }

      it "can only have trainees on the hpitt_postgrad route" do
        expect(subject).to be_valid
      end

      context "with trainees on any other route" do
        let(:training_route) { TRAINING_ROUTE_ENUMS[:early_years_undergrad] }

        it { is_expected.not_to be_valid }
      end

      context "when the provider is not an hpitt provider" do
        let(:provider) { build(:provider) }

        it "cannot have trainees on the hpitt_postgrad route" do
          expect(subject).not_to be_valid
        end
      end
    end

    context "slug" do
      subject { create(:trainee) }

      it { is_expected.to validate_uniqueness_of(:slug).case_insensitive }

      context "immutability" do
        let(:original_slug) { subject.slug.dup }

        before do
          original_slug
          subject.regenerate_slug
          subject.reload
        end

        it "is immutable once created" do
          expect(subject.slug).to eq(original_slug)
        end
      end
    end
  end

  context "callbacks" do
    describe "submission_ready" do
      context "when complection is trackable" do
        subject { create(:trainee, :completed, :draft) }

        context "when trainee has not changed" do
          it "does not toggle the submission_ready field" do
            expect { subject.save }.not_to change { subject.submission_ready }
          end
        end

        context "when trainee has changed with invalid information" do
          before do
            subject.first_names = nil
          end

          it "toggles the submission_ready field" do
            expect { subject.save }.to change { subject.submission_ready }
            expect(subject).not_to(be_submission_ready)
          end
        end

        context "when trainee is not a draft" do
          subject { create(:trainee, :submitted_for_trn) }

          before do
            subject.first_names = nil
          end

          it "toggles the submission_ready field" do
            expect { subject.save }.to change { subject.submission_ready }
            expect(subject).not_to(be_submission_ready)
          end

          it "calls the Submissions::MissingDataValidator" do
            expect(Submissions::MissingDataValidator).to receive(:new).with(trainee: subject).and_return(double(valid?: true))
            subject.save
          end
        end
      end

      context "when completion is not trackable" do
        subject { create(:trainee, :completed, :recommended_for_award) }

        before do
          subject.first_names = nil
        end

        it "does not toggle the submission_ready field" do
          expect { subject.save }.not_to change { subject.submission_ready }
        end
      end
    end
  end

  context "class methods" do
    describe ".dttp_id" do
      let(:uuid) { "2795182a-43b2-4543-bf83-ad95fbfce7fd" }

      context "when passed as an attribute" do
        it "uses the attribute" do
          trainee = create(:trainee, dttp_id: uuid)
          expect(trainee.dttp_id).to eq(uuid)
        end
      end

      context "when it has already been set" do
        it "raises an exception" do
          trainee = create(:trainee, dttp_id: uuid)

          expect { trainee.dttp_id = uuid }.to raise_error(LockedAttributeError)
        end
      end

      describe "validation" do
        context "when training route is present" do
          subject { build(:trainee, training_route: TRAINING_ROUTE_ENUMS[:assessment_only]) }

          it "is valid" do
            expect(subject).to be_valid
          end
        end

        context "when training route is not present" do
          it "is not valid" do
            expect(subject).not_to be_valid
            expect(subject.errors.attribute_names).to include(:training_route)
          end
        end
      end
    end
  end

  context "instance methods" do
    subject { create(:trainee) }

    describe "#sha" do
      context "when a field value has changed" do
        it "returns a different value if the trainee state has changed" do
          expect { subject.first_names = "Bob" }.to(change { subject.sha })
        end
      end

      context "when a field is added with no value" do
        # we don't want the sha to change from a new field being added to the schema
        # unless it has a value

        before do
          def subject.serializable_hash(*args)
            super.merge("new_field" => nil)
          end
        end

        it "does not alter the sha" do
          expect {
            def subject.serializable_hash(*args)
              super.merge("new_field" => nil)
            end
          }.not_to(change { subject.sha })
        end
      end

      context "when the dttp_update_sha is updated" do
        it "doesn't alter the sha" do
          expect {
            subject.update(dttp_update_sha: subject.sha)
          }.not_to(change { subject.sha })
        end
      end
    end

    describe "#training_route_manager" do
      it "returns an instance of TrainingRouteManager" do
        expect(subject.training_route_manager).to be_an_instance_of(TrainingRouteManager)
      end
    end

    describe "#requires_placement_details?" do
      it "is delegated to TrainingRouteManager" do
        expect(subject.training_route_manager).to receive(:requires_placement_details?)
        subject.requires_placement_details?
      end
    end

    describe "#apply_application?" do
      subject { trainee.apply_application? }

      context "the trainee has an associated apply application" do
        let(:trainee) { create(:trainee, :with_apply_application) }

        it { is_expected.to be true }
      end

      context "the trainee does not have an associated apply application" do
        let(:trainee) { create(:trainee) }

        it { is_expected.to be false }
      end
    end

    describe "#timeline" do
      context "with cache" do
        before do
          allow(Rails.cache).to receive(:fetch).and_return(double)
        end

        it "caches the timeline event after the initial request" do
          expect(Trainees::CreateTimeline).not_to receive(:call)

          subject.timeline
        end
      end

      context "without cache" do
        it "calls Trainees::CreateTimeline" do
          expect(Trainees::CreateTimeline).to receive(:call).once

          subject.timeline
        end
      end
    end
  end

  describe "#with_name_trainee_id_or_trn_like" do
    let(:other_trainee) { create(:trainee) }
    let(:matching_trainee) do
      create(:trainee, middle_names: "Firstmiddle Secondmiddle", trn: "123")
    end

    subject { described_class.with_name_trainee_id_or_trn_like(search_term) }

    shared_examples_for "a working search" do
      it "returns the matching trainee" do
        expect(subject).to contain_exactly(matching_trainee)
      end
    end

    context "with an exactly matching first name" do
      let(:search_term) { matching_trainee.first_names }

      it_behaves_like "a working search"
    end

    context "with exactly matching (second) middle name" do
      let(:search_term) { "Secondmiddle" }

      it_behaves_like "a working search"
    end

    context "with exactly matching last name" do
      let(:search_term) { matching_trainee.last_name }

      it_behaves_like "a working search"
    end

    context "with a matching trainee id" do
      let(:search_term) { matching_trainee.trn }

      it_behaves_like "a working search"
    end

    context "with extra spaces in the search term" do
      let(:search_term) { "Firstmiddle  Secondmiddle" }

      it_behaves_like "a working search"
    end

    context "with incorrect case" do
      let(:search_term) { "firstMiddle" }

      it_behaves_like "a working search"
    end

    context "with partial search term" do
      let(:search_term) { "First" }

      it_behaves_like "a working search"
    end
  end

  context "ordering scope" do
    let(:deferred_trainee_a) { create(:trainee, :deferred, updated_at: 1.day.ago, last_name: "Smith") }
    let(:submitted_for_trn_trainee_b) { create(:trainee, :submitted_for_trn, updated_at: 1.hour.ago, last_name: "Doe") }
    let(:draft_trainee_c) { create(:trainee, :draft, updated_at: 1.week.ago, last_name: "Jones") }
    let(:draft_trainee_d) { create(:trainee, :draft, updated_at: 1.month.ago, last_name: "Joker") }

    let(:save_trainees) do
      [
        deferred_trainee_a,
        draft_trainee_c,
        submitted_for_trn_trainee_b,
        draft_trainee_d,
      ]
    end

    before do
      save_trainees
    end

    describe "#ordered_by_updated_at" do
      let(:expected_order) do
        [
          submitted_for_trn_trainee_b,
          deferred_trainee_a,
          draft_trainee_c,
          draft_trainee_d,
        ]
      end

      it "orders the trainees by updated_at in descending order" do
        expect(save_trainees).not_to eq(expected_order)
        expect(Trainee.ordered_by_updated_at).to eq(expected_order)
      end
    end

    describe "#ordered_by_last_name" do
      let(:expected_order) do
        [
          submitted_for_trn_trainee_b,
          draft_trainee_d,
          draft_trainee_c,
          deferred_trainee_a,
        ]
      end

      it "orders the trainees by last name in ascending order" do
        expect(save_trainees).not_to eq(expected_order)

        expect(Trainee.ordered_by_last_name).to eq(expected_order)
      end
    end

    describe "#ordered_by_drafts" do
      let(:expected_order) do
        [
          draft_trainee_c,
          draft_trainee_d,
          deferred_trainee_a,
          submitted_for_trn_trainee_b,
        ]
      end

      it "orders the trainees by drafts first, then any other state" do
        expect(save_trainees).not_to eq(expected_order)

        expect(Trainee.ordered_by_drafts.first(2)).to match_array([draft_trainee_d, draft_trainee_c])
      end
    end

    describe "#ordered_by_drafts_then_by" do
      context "last_name field" do
        let(:expected_order) do
          [
            draft_trainee_d,
            draft_trainee_c,
            submitted_for_trn_trainee_b,
            deferred_trainee_a,
          ]
        end

        it "orders the trainees by drafts first, then any other state, then by last_name" do
          expect(save_trainees).not_to eq(expected_order)

          expect(Trainee.ordered_by_drafts_then_by(:last_name)).to eq(expected_order)
        end
      end

      context "updated_at field" do
        let(:expected_order) do
          [
            draft_trainee_c,
            draft_trainee_d,
            submitted_for_trn_trainee_b,
            deferred_trainee_a,
          ]
        end

        it "orders the trainees by drafts first, then any other state, then by updated_at" do
          expect(save_trainees).not_to eq(expected_order)

          expect(Trainee.ordered_by_drafts_then_by(:updated_at)).to eq(expected_order)
        end
      end
    end
  end

  describe "#with_subject_or_allocation_subject" do
    let!(:trainee_with_subject) { create(:trainee, course_subject_one: CourseSubjects::BIOLOGY) }
    let!(:trainee_without_subject) { create(:trainee, course_subject_one: CourseSubjects::MATHEMATICS) }

    subject { described_class.with_subject_or_allocation_subject(CourseSubjects::BIOLOGY) }

    it { is_expected.to eq([trainee_with_subject]) }

    context "with lowercase subject name" do
      let!(:trainee_with_subject) { create(:trainee, course_subject_one: "biology") }

      it { is_expected.to eq([trainee_with_subject]) }
    end

    context "with multiple subjects" do
      let!(:trainee_with_subject_two) do
        create(:trainee,
               course_subject_one: CourseSubjects::MATHEMATICS,
               course_subject_two: CourseSubjects::BIOLOGY)
      end

      let!(:trainee_with_subject_three) do
        create(:trainee,
               course_subject_one: CourseSubjects::MATHEMATICS,
               course_subject_two: CourseSubjects::SOCIAL_SCIENCES,
               course_subject_three: CourseSubjects::BIOLOGY)
      end

      it { is_expected.to match_array([trainee_with_subject, trainee_with_subject_two, trainee_with_subject_three]) }
    end

    context "with allocation subject" do
      let(:subject_specialism) { create(:subject_specialism) }
      let!(:trainee_with_subject) { create(:trainee, course_subject_one: subject_specialism.name) }

      subject { described_class.with_subject_or_allocation_subject(subject_specialism.allocation_subject.name) }

      it { is_expected.to eq([trainee_with_subject]) }
    end
  end

  describe "auditing" do
    it { is_expected.to be_audited.associated_with(:provider) }
  end

  describe "#set_early_years_course_subject" do
    let(:trainee) { build(:trainee, :early_years_undergrad) }

    it "sets course_subject_one to early years teaching and age range to 0-5" do
      trainee.set_early_years_course_details
      expect(trainee.course_subject_one).to eq(CourseSubjects::EARLY_YEARS_TEACHING)
      expect(trainee.course_age_range).to eq(AgeRange::ZERO_TO_FIVE)
    end
  end

  context "first name and last name have inside and trailing spaces" do
    let(:trainee) { create(:trainee, first_names: " Joe   Black ", last_name: " Bloggs   ") }

    it "all inside and outside spaces are removed" do
      expect(trainee.first_names).to eq("Joe Black")
      expect(trainee.last_name).to eq("Bloggs")
    end
  end

  describe "#course_duration_in_years" do
    it "returns nil if no itt start/end dates set" do
      trainee = Trainee.new(itt_start_date: Time.zone.today, itt_end_date: nil)
      expect(trainee.course_duration_in_years).to be_nil
      trainee = Trainee.new(itt_start_date: nil, itt_end_date: Time.zone.today)
      expect(trainee.course_duration_in_years).to be_nil
    end

    it "returns 1 year" do
      trainee = Trainee.new(itt_start_date: "2021-09-10".to_date, itt_end_date: "2022-07-01".to_date)
      expect(trainee.course_duration_in_years).to eq(1)
    end

    it "returns 2 years" do
      trainee = Trainee.new(itt_start_date: "2021-09-10".to_date, itt_end_date: "2023-07-01".to_date)
      expect(trainee.course_duration_in_years).to eq(2)
    end
  end

  describe "#short_name" do
    it "returns short name" do
      trainee = Trainee.new(first_names: "Joe", middle_names: nil, last_name: "Blogs")
      expect(trainee.short_name).to eql("Joe Blogs")
    end

    it "returns name without middle names" do
      trainee = Trainee.new(first_names: "Joe", middle_names: "Smith", last_name: "Blogs")
      expect(trainee.short_name).to eql("Joe Blogs")
    end
  end

  describe "#full_name" do
    it "returns full name" do
      trainee = Trainee.new(first_names: "Joe", middle_names: nil, last_name: "Blogs")
      expect(trainee.full_name).to eql("Joe Blogs")

      trainee = Trainee.new(first_names: "Joe", middle_names: "Smith", last_name: "Blogs")
      expect(trainee.full_name).to eql("Joe Smith Blogs")
    end
  end

  describe "#duplicate?" do
    let(:trainee) { create(:trainee) }

    before { trainee.dup.tap { |t| t.slug = t.generate_slug }.save }

    it "returns true if another trainee has the same nam, date of birth and email address" do
      expect(trainee.duplicate?).to eq(true)
    end
  end
end
