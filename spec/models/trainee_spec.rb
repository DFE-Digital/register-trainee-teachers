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
        TRAINING_ROUTE_ENUMS[:iqts] => 12,
        TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship] => 14,
      )
    end

    it { is_expected.to define_enum_for(:sex).with_values(male: 0, female: 1, other: 2, sex_not_provided: 3, prefer_not_to_say: 4) }

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
        ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary] => 6,
        ROUTE_INITIATIVES_ENUMS[:international_relocation_payment] => 7,
        ROUTE_INITIATIVES_ENUMS[:abridged_itt_course] => 8,
        ROUTE_INITIATIVES_ENUMS[:primary_mathematics_specialist] => 9,
        ROUTE_INITIATIVES_ENUMS[:additional_itt_place_for_pe_with_a_priority_subject] => 10,
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
        BURSARY_TIER_ENUMS[:tier_one] => 1,
        BURSARY_TIER_ENUMS[:tier_two] => 2,
        BURSARY_TIER_ENUMS[:tier_three] => 3,
      )
    end
  end

  describe "scopes" do
    describe ".on_early_years_routes" do
      it "returns trainees with the correct training route and state" do
        create(:trainee, :school_direct_salaried)
        early_years_trainee = create(:trainee, training_route: EARLY_YEARS_TRAINING_ROUTES.values.sample)

        expect(described_class.on_early_years_routes).to contain_exactly(early_years_trainee)
      end
    end

    describe ".with_apply_application" do
      let!(:manual_trainee) { create(:trainee) }
      let!(:apply_trainee) { create(:trainee, :with_apply_application) }

      it "returns trainees from apply" do
        expect(described_class.with_apply_application).to contain_exactly(apply_trainee)
      end
    end

    describe ".imported_from_hesa" do
      let!(:draft_trainee) { create(:trainee) }
      let!(:hesa_trainee) { create(:trainee, :imported_from_hesa) }

      it "returns trainees created from hesa" do
        expect(described_class.imported_from_hesa).to contain_exactly(hesa_trainee)
      end
    end

    describe ".in_training" do
      let!(:submitted_trainee) { create(:trainee, :submitted_for_trn, itt_start_date: 2.days.ago) }
      let!(:trn_received_trainee) { create(:trainee, :trn_received, itt_start_date: 2.days.ago) }
      let!(:recommended_for_award_trainee) { create(:trainee, :recommended_for_award, itt_start_date: 2.days.ago) }
      let!(:recommended_for_award_trainee_in_future) { create(:trainee, :recommended_for_award, itt_start_date: Time.zone.today + 1.day) }
      let!(:deferred_trainee) { create(:trainee, :deferred, itt_start_date: 2.days.ago) }

      it "returns trainees in the submitted, trn_received and recommended for award states with start dates in the past" do
        expect(described_class.in_training).to include(submitted_trainee, trn_received_trainee, recommended_for_award_trainee)
        expect(described_class.in_training).not_to include(recommended_for_award_trainee_in_future, deferred_trainee)
      end
    end

    describe ".course_not_yet_started" do
      let!(:draft_trainee) { create(:trainee, :draft) }
      let!(:recommended_for_award_trainee_in_past) { create(:trainee, :recommended_for_award, itt_start_date: 1.day.ago) }
      let!(:recommended_for_award_trainee_in_future) { create(:trainee, :recommended_for_award, itt_start_date: Time.zone.today + 1.day) }

      it "returns non draft trainees with start dates in the future" do
        expect(described_class.course_not_yet_started).to include(recommended_for_award_trainee_in_future)
        expect(described_class.course_not_yet_started).not_to include(draft_trainee, recommended_for_award_trainee_in_past)
      end
    end

    describe ".complete" do
      let!(:complete_trainee) { create(:trainee, :completed) }
      let!(:incomplete_recommended_trainee) { create(:trainee, :recommended_for_award, :incomplete) }
      let!(:incomplete_awarded_trainee) { create(:trainee, :awarded, :incomplete) }
      let!(:incomplete_withdrawn_trainee) { create(:trainee, :withdrawn, :incomplete) }
      let!(:incomplete_trn_received) { create(:trainee, :trn_received, :incomplete) }

      it "returns complete trainees, incomplete recommended trainees, incomplete awarded trainees, incomplete withdrawn trainees" do
        expect(described_class.complete).to include(complete_trainee, incomplete_recommended_trainee, incomplete_awarded_trainee, incomplete_withdrawn_trainee)
      end

      it "does not return incomplete trainees" do
        expect(described_class.complete).not_to include(incomplete_trn_received)
      end
    end

    describe ".potential_duplicates_of and .not_marked_as_duplicate" do
      let(:trainee1) { create(:trainee, :in_progress, :with_training_route) }
      let(:provider) { trainee1.provider }
      let!(:trainee2) { create(:trainee, :in_progress, provider: provider, last_name: trainee1.last_name, date_of_birth: trainee1.date_of_birth, training_route: trainee1.training_route, start_academic_cycle: trainee1.start_academic_cycle) }

      it "returns trainees with the same last_name, date_of_birth, training_route and start_academic_cycle" do
        expect(described_class.potential_duplicates_of(trainee1).not_marked_as_duplicate).to contain_exactly(trainee2)
      end

      context "when trainee is marked as duplicate" do
        let!(:potential_duplicate1) { create(:potential_duplicate_trainee, trainee: trainee1) }
        let!(:potential_duplicate2) { create(:potential_duplicate_trainee, trainee: trainee2, group_id: potential_duplicate1.group_id) }

        it "`potential_duplicates_of` combined with `not_marked_as_duplicate` does not return trainees with the same last_name, date_of_birth, training_route and start_academic_cycle" do
          expect(described_class.potential_duplicates_of(trainee1).not_marked_as_duplicate).to be_empty
        end

        it "`potential_duplicates_of` alone returns trainees with the same last_name, date_of_birth, training_route and start_academic_cycle" do
          expect(described_class.potential_duplicates_of(trainee1)).to contain_exactly(trainee2)
        end
      end
    end
  end

  context "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:apply_application).optional }
    it { is_expected.to have_one(:training_partner_school).through(:training_partner) }
    it { is_expected.to belong_to(:training_partner).optional }
    it { is_expected.to belong_to(:employing_school).class_name("School").optional }
    it { is_expected.to have_one(:trs_trn_request).dependent(:destroy) }
    it { is_expected.to have_many(:degrees).dependent(:destroy) }
    it { is_expected.to have_many(:nationalisations).dependent(:destroy).inverse_of(:trainee) }
    it { is_expected.to have_many(:nationalities).through(:nationalisations) }
    it { is_expected.to have_many(:trainee_disabilities).dependent(:destroy).inverse_of(:trainee) }
    it { is_expected.to have_many(:disabilities).through(:trainee_disabilities) }
    it { is_expected.to have_many(:hesa_students).inverse_of(:trainee) }
    it { is_expected.to have_many(:recommendations_upload_rows) }
    it { is_expected.to have_many(:withdrawal_reasons) }

    describe "#published_course" do
      let(:same_code) { "1TX" }
      let(:provider_a) { create(:provider, :with_courses, course_code: same_code) }
      let!(:provider_b) { create(:provider, :with_courses, course_code: same_code) }

      subject { create(:trainee, provider: provider_a, course_uuid: provider_a.courses.first.uuid).published_course.provider }

      it { is_expected.to eq(provider_a) }
    end
  end

  describe "#available_courses" do
    let(:course_route) { TRAINING_ROUTES_FOR_COURSE.keys.first }
    let!(:physics_course) { create(:course, route: course_route, name: "Physics", accredited_body_code: provider.code) }
    let!(:citizenship_course) { create(:course, route: course_route, name: "Citizenship", accredited_body_code: provider.code) }
    let!(:economics_course) { create(:course, route: TRAINING_ROUTES_FOR_COURSE.keys.last, name: "Economics", accredited_body_code: provider.code) }
    let(:trainee) { create(:trainee, training_route: course_route) }
    let(:provider) { trainee.provider }

    subject { trainee.available_courses(course_route) }

    it "returns courses available for the route ordered by name" do
      expect(subject).to eq([citizenship_course, physics_course])
    end

    context "with a trainee from apply" do
      let(:trainee) { create(:trainee, :with_apply_application) }

      it "returns all courses available for the route ordered by name" do
        expect(subject).to eq([citizenship_course, physics_course])
      end

      it "does not return courses that are associated with the provider but not the route" do
        expect(subject).not_to eq([citizenship_course, economics_course, physics_course])
      end
    end
  end

  context "slug" do
    subject { create(:trainee) }

    let(:trainee_with_matching_slug) { create(:trainee, slug: subject.slug.downcase) }

    it "ensures unique case insensitive slugs" do
      expect { trainee_with_matching_slug } .to raise_error(ActiveRecord::RecordNotUnique)
    end

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

  context "callbacks" do
    context "academic cycles" do
      subject { create(:trainee, :submitted_for_trn) }

      before do
        allow(Trainees::SetAcademicCycles).to receive(:call).with(subject)
      end

      it "sets/recalculates the the start and end academic cycles" do
        expect(Trainees::SetAcademicCycles).to receive(:call).with(trainee: subject)
        subject.save
      end
    end

    describe "searchable" do
      let(:trainee) do
        create(
          :trainee,
          first_names: "John",
          middle_names: "James",
          last_name: "Smith",
          provider_trainee_id: "25/26-1",
          trn: "5120560",
        )
      end

      it "updates the tsvector column with relevant info when the trainee is updated" do
        expect(trainee.searchable).to eq("'25/26-1':4 '5120560':5 'james':2 'john':1 'smith':3")
      end
    end

    describe "submission_ready" do
      context "when completion is trackable" do
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

    describe "clear_lead_partner_id" do
      subject { create(:trainee, :with_lead_partner) }

      context "when lead_partner_not_applicable is true" do
        it "changes lead_partner_id to nil" do
          expect {
            subject.lead_partner_not_applicable = true
            subject.save!
          }.to change(subject, :training_partner_id).from(Integer).to nil
        end
      end

      context "when lead_partner_not_applicable is false" do
        it "does not change lead_partner_id" do
          expect {
            subject.lead_partner_not_applicable = false
            subject.save!
          }.to not_change(subject, :training_partner_id)
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
    subject { trainee }

    let(:trainee) { create(:trainee) }

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
            trainee.update(dttp_update_sha: subject.sha)
          }.not_to(change { subject.sha })
        end
      end
    end

    describe "#training_route_manager" do
      it "returns an instance of TrainingRouteManager" do
        expect(subject.training_route_manager).to be_an_instance_of(TrainingRouteManager)
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

    describe "#derived_record_source" do
      subject { trainee.derived_record_source }

      context "manual record source" do
        let(:trainee) { create(:trainee) }

        it "returns manual record source" do
          expect(subject).to eql("manual")
        end
      end

      context "dttp record source" do
        let(:trainee) { create(:trainee, :created_from_dttp) }

        it "returns dttp record source" do
          expect(subject).to eql("dttp")
        end
      end

      context "apply record source" do
        let(:trainee) { create(:trainee, :with_apply_application) }

        it "returns apply record source" do
          expect(subject).to eql("apply")
        end
      end

      context "hesa record source" do
        let(:trainee) { create(:trainee, :imported_from_hesa) }

        it "returns hesa record source" do
          expect(subject).to eql("hesa")
        end
      end

      context "api record source" do
        let(:trainee) { create(:trainee, :created_from_api) }

        it "returns api record source" do
          expect(subject).to eql("api")
        end
      end

      context "csv record source" do
        let(:trainee) { create(:trainee, :created_from_csv) }

        it "returns csv record source" do
          expect(subject).to eql("csv")
        end
      end
    end
  end

  describe "#with_name_provider_trainee_id_or_trn_like" do
    let(:other_trainee) { create(:trainee) }
    let(:matching_trainee) do
      create(:trainee, middle_names: "Firstmiddle Secondmiddle", trn: "123")
    end

    subject { described_class.with_name_provider_trainee_id_or_trn_like(search_term) }

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
    let(:deferred_trainee_a) { create(:trainee, :deferred, last_name: "Smith") }
    let(:submitted_for_trn_trainee_b) { create(:trainee, :submitted_for_trn, last_name: "Doe") }
    let(:draft_trainee_c) { create(:trainee, :draft, last_name: "Jones") }
    let(:draft_trainee_d) { create(:trainee, :draft, last_name: "Joker") }

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
      submitted_for_trn_trainee_b.update!(updated_at: 1.hour.ago)
      deferred_trainee_a.update!(updated_at: 1.day.ago)
      draft_trainee_c.update!(updated_at: 1.week.ago)
      draft_trainee_d.update!(updated_at: 1.month.ago)
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

      it { is_expected.to contain_exactly(trainee_with_subject, trainee_with_subject_two, trainee_with_subject_three) }
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
      expect(trainee.course_age_range).to eq(DfE::ReferenceData::AgeRanges::ZERO_TO_FIVE)
      expect(trainee.course_allocation_subject).to eq(AllocationSubject.find_by(name: AllocationSubjects::EARLY_YEARS_ITT))
      expect(trainee.course_education_phase).to eq(COURSE_EDUCATION_PHASE_ENUMS[:early_years])
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

  describe "#inactive?" do
    context "when a trainee is withdrawn" do
      let(:trainee) { create(:trainee, state: "withdrawn") }

      it "returns true" do
        expect(trainee.inactive?).to be(true)
      end
    end

    context "when a trainee is awarded in a previous cycle" do
      let(:trainee) { create(:trainee, state: "awarded", awarded_at: "31/02/2020") }

      before do
        create(:academic_cycle, start_date: "01/9/2021", end_date: "31/8/2022")
        create(:academic_cycle, start_date: "01/9/2020", end_date: "31/8/2021")
        create(:academic_cycle, start_date: "01/9/2019", end_date: "31/8/2020")
      end

      it "returns true" do
        expect(trainee.inactive?).to be(true)
      end
    end

    context "when a trainee is awarded in a current cycle" do
      let(:trainee) { create(:trainee, state: "awarded", awarded_at: 2.days.ago) }

      before do
        create(:academic_cycle, start_date: "01/9/2021", end_date: Time.zone.now)
        create(:academic_cycle, start_date: "01/9/2020", end_date: "31/8/2021")
        create(:academic_cycle, start_date: "01/9/2019", end_date: "31/8/2020")
      end

      it "returns false" do
        expect(trainee.inactive?).to be(false)
      end
    end

    context "when a trainee is awaiting a trn" do
      let(:trainee) { create(:trainee, state: "awarded", awarded_at: 2.days.ago) }

      it "returns false" do
        expect(trainee.inactive?).to be(false)
      end
    end
  end

  describe "#duplicate?" do
    let(:trainee) { create(:trainee) }

    before { trainee.dup.tap { |t| t.slug = t.generate_slug }.save }

    it "returns true if another trainee has the same name, date of birth and email address" do
      expect(trainee.duplicate?).to be(true)
    end
  end
end
