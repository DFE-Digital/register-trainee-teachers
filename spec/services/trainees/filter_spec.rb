# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe Filter do
    subject { described_class.call(trainees:, filters:) }

    let(:draft_trainee) { create(:trainee, :incomplete_draft, :created_manually, first_names: "Draft") }
    let(:apply_draft_trainee) { create(:trainee, :with_apply_application, first_names: "Apply") }
    let(:filters) { nil }
    let(:trainees) { Trainee.all }

    before do
      allow(Trainees::SetAcademicCycles).to receive(:call) # deactivate so it doesn't override factories
    end

    it { is_expected.to match_array(trainees) }

    context "when an empty trainee exists" do
      let!(:empty_trainee) do
        Trainee.create(provider_id: draft_trainee.provider.id,
                       training_route: TRAINING_ROUTE_ENUMS[:assessment_only])
      end

      it { is_expected.not_to include(empty_trainee) }
    end

    context "when HESA TRN data trainee exists" do
      let!(:hesa_trn_data_trainee) { create(:trainee, record_source: Trainee::HESA_TRN_DATA_SOURCE) }

      it { is_expected.to include(hesa_trn_data_trainee) }
    end

    context "when a HESA collection trainee exists" do
      let!(:hesa_collection_trainee) { create(:trainee, record_source: Trainee::HESA_COLLECTION_SOURCE) }

      it { is_expected.to include(hesa_collection_trainee) }
    end

    context "when a trainee exists with nil record source" do
      let!(:nil_record_source_trainee) { create(:trainee, record_source: nil) }

      it { is_expected.to include(nil_record_source_trainee) }
    end

    context "with academic_year filter" do
      let!(:old_cycle) { create(:academic_cycle, one_before_previous_cycle: true) }
      let(:previous_cycle) { create(:academic_cycle, previous_cycle: true) }
      let(:current_cycle) { create(:academic_cycle, :current) }
      let!(:next_cycle) { create(:academic_cycle, next_cycle: true) }
      let(:current_year_string) { current_cycle.start_year.to_s }
      let(:previous_year_string) { previous_cycle.start_year.to_s }

      context "with a trainee with start academic cycle in the selected academic year" do
        let!(:trainee) { create(:trainee, :trn_received, start_academic_cycle: current_cycle, end_academic_cycle: next_cycle) }
        let(:filters) { { academic_year: [current_year_string] } }

        it { is_expected.to include(trainee) }
      end

      context "with a trainee with end academic cycle in the selected academic year" do
        let!(:trainee) { create(:trainee, :trn_received, start_academic_cycle: previous_cycle, end_academic_cycle: current_cycle) }
        let(:filters) { { academic_year: [current_year_string] } }

        it { is_expected.to include(trainee) }
      end

      context "with a trainee that has start and end cycles spanning the selected academic year" do
        let!(:trainee) { create(:trainee, :trn_received, start_academic_cycle: previous_cycle, end_academic_cycle: next_cycle) }
        let(:filters) { { academic_year: [current_year_string] } }

        it { is_expected.to include(trainee) }
      end

      context "when two academic years are selected" do
        let!(:previous_year_trainee) { create(:trainee, :trn_received, start_academic_cycle: old_cycle, end_academic_cycle: previous_cycle) }
        let!(:current_year_trainee) { create(:trainee, :trn_received, start_academic_cycle: current_cycle, end_academic_cycle: next_cycle) }
        let(:filters) { { academic_year: [current_year_string, previous_year_string] } }

        it { is_expected.to include(current_year_trainee, previous_year_trainee) }
      end

      context "when a trainee spans multiple academic years" do
        let!(:trainee) { create(:trainee, :trn_received, start_academic_cycle: previous_cycle, end_academic_cycle: next_cycle) }
        let(:filters) { { academic_year: [current_year_string, previous_year_string] } }

        it "only returns trainee once" do
          expect(subject).to contain_exactly(trainee)
        end
      end
    end

    context "with training_route filter" do
      let!(:provider_led_postgrad_trainee) { create(:trainee, :provider_led_postgrad) }
      let(:filters) { { training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad] } }

      it { is_expected.to eq([provider_led_postgrad_trainee]) }
    end

    context "with has_trn filter" do
      let!(:trainee_without_trn) { create(:trainee, :submitted_for_trn) }
      let!(:trainee_with_trn) { create(:trainee, :trn_received) }

      context "when has_trn is nil" do
        let(:filters) { { has_trn: nil } }

        it do
          expect(subject).to contain_exactly(trainee_without_trn, trainee_with_trn)
        end
      end

      context "when has_trn is true" do
        let(:filters) { { has_trn: true } }

        it { is_expected.to contain_exactly(trainee_with_trn) }
      end

      context "when has_trn is false" do
        let(:filters) { { has_trn: false } }

        it { is_expected.to contain_exactly(trainee_without_trn) }
      end
    end

    context "with level filter" do
      let!(:early_years_trainee) { create(:trainee, :early_years_undergrad) }
      let!(:primary_trainee) { create(:trainee, :with_primary_education) }
      let!(:secondary_trainee) { create(:trainee, :with_secondary_education) }

      context "early_years" do
        let(:filters) { { level: %w[early_years] } }

        it { is_expected.to contain_exactly(early_years_trainee) }
      end

      context "early_years and primary" do
        let(:filters) { { level: %w[early_years primary] } }

        it { is_expected.to contain_exactly(early_years_trainee, primary_trainee) }
      end

      context "primary" do
        let(:filters) { { level: %w[primary] } }

        it { is_expected.to contain_exactly(primary_trainee) }
      end

      context "secondary" do
        let(:filters) { { level: %w[secondary] } }

        it { is_expected.to contain_exactly(secondary_trainee) }
      end
    end

    context "with status filter" do
      let!(:submitted_for_trn_trainee) { create(:trainee, :submitted_for_trn, :itt_start_date_in_the_past) }
      let!(:qts_awarded_trainee) { create(:trainee, :qts_awarded, :itt_start_date_in_the_past) }
      let!(:eyts_awarded_trainee) { create(:trainee, :eyts_awarded, :itt_start_date_in_the_past) }
      let!(:not_yet_started_trainee) { create(:trainee, :trn_received, :itt_start_date_in_the_future) }
      let!(:withdrawn_trainee) { create(:trainee, :withdrawn, :itt_start_date_in_the_past) }
      let!(:deferred_trainee) { create(:trainee, :deferred, :itt_start_date_in_the_past) }

      context "with in_training" do
        let(:filters) { { status: %w[in_training] } }

        it { is_expected.to contain_exactly(submitted_for_trn_trainee) }
      end

      context "with awarded" do
        let(:filters) { { status: %w[awarded] } }

        it { is_expected.to contain_exactly(qts_awarded_trainee, eyts_awarded_trainee) }
      end

      context "with in_training, awarded" do
        let(:filters) { { status: %w[in_training awarded] } }

        it { is_expected.to contain_exactly(submitted_for_trn_trainee, qts_awarded_trainee, eyts_awarded_trainee) }
      end

      context "with withdrawn" do
        let(:filters) { { status: %w[withdrawn] } }

        it { is_expected.to contain_exactly(withdrawn_trainee) }
      end

      context "with deferred" do
        let(:filters) { { status: %w[deferred] } }

        it { is_expected.to contain_exactly(deferred_trainee) }
      end

      context "with course not yet started" do
        let(:filters) { { status: %w[course_not_yet_started] } }

        it { is_expected.to contain_exactly(not_yet_started_trainee) }
      end
    end

    context "with subject filter" do
      let(:subject_name) { CourseSubjects::BIOLOGY }
      let!(:trainee_with_subject) { create(:trainee, course_subject_one: subject_name) }
      let(:filters) { { subject: subject_name } }

      it { is_expected.to eq([trainee_with_subject]) }
    end

    context "with subject filter set to Sciences - biology, chemistry, physics" do
      let(:subject_name) { Filter::ALL_SCIENCES_FILTER }
      let!(:trainee_with_biology) { create(:trainee, course_subject_one: "Biology") }
      let!(:trainee_with_chemistry) { create(:trainee, course_subject_one: "Chemistry") }
      let!(:trainee_with_physics) { create(:trainee, course_subject_one: "Physics") }
      let(:filters) { { subject: subject_name } }

      it { is_expected.to contain_exactly(trainee_with_biology, trainee_with_chemistry, trainee_with_physics) }
    end

    context "with text_search filter" do
      let!(:named_trainee) { create(:trainee, first_names: "Boaty McBoatface") }
      let(:filters) { { text_search: "Boaty" } }

      it { is_expected.to eq([named_trainee]) }
    end

    context "with record_completion filter" do
      let!(:non_draft_trainee) { create(:trainee, :submitted_for_trn) }

      context "complete" do
        let(:filters) { { record_completion: ["complete"] } }

        it { is_expected.to contain_exactly(non_draft_trainee) }
      end

      context "incomplete" do
        let(:filters) { { record_completion: ["incomplete"] } }

        it { is_expected.to contain_exactly(draft_trainee, apply_draft_trainee) }
      end
    end

    context "start and end year filters" do
      let!(:trainee) { create(:trainee, start_academic_cycle: academic_cycle) }
      let(:year_filter) { "#{current_academic_year} to #{current_academic_year + 1}" }
      let(:academic_cycle) { create(:academic_cycle, :current) }

      context "with start_year filter" do
        let(:filters) { { start_year: year_filter } }

        context "trainee starting in that year" do
          it "returns the trainee" do
            expect(subject).to contain_exactly(trainee)
          end
        end

        context "trainee not starting in that year" do
          let(:academic_cycle) { create(:academic_cycle, next_cycle: true) }

          before { create(:academic_cycle, :current) }

          it "does not return the trainee" do
            expect(subject).to be_empty
          end
        end

        context "trainee start_academic_cycle is blank" do
          let(:academic_cycle) { nil }

          before { create(:academic_cycle, :current) }

          it "returns the trainee" do
            expect(subject).to contain_exactly(trainee)
          end
        end
      end

      context "with end_year filter" do
        let!(:trainee) { create(:trainee, end_academic_cycle: academic_cycle) }
        let(:filters) { { end_year: year_filter } }

        context "trainee ending in that year" do
          it "returns the trainee" do
            expect(subject).to contain_exactly(trainee)
          end
        end

        context "trainee not ending in that year" do
          let(:academic_cycle) { create(:academic_cycle, next_cycle: true) }

          before { create(:academic_cycle, :current) }

          it "does not return the trainee" do
            expect(subject).to be_empty
          end
        end

        context "trainee end_academic_cycle is blank" do
          let(:academic_cycle) { nil }

          before { create(:academic_cycle, :current) }

          it "returns the trainee" do
            expect(subject).to contain_exactly(trainee)
          end
        end
      end
    end

    describe "record source filter" do
      let!(:dttp_trainee) { create(:trainee, :created_from_dttp, first_names: "DTTP") }
      let(:filters) { { record_source: filter_value } }

      context "with record_source filter set to apply" do
        let(:filter_value) { %w[apply] }

        it { is_expected.to contain_exactly(apply_draft_trainee) }
      end

      context "with record_source filter set to manual" do
        let(:filter_value) { %w[manual] }

        it { is_expected.to contain_exactly(draft_trainee) }
      end

      context "with record_source filter set to dttp" do
        let(:filter_value) { %w[dttp] }

        it { is_expected.to contain_exactly(dttp_trainee) }
      end

      context "with record_source filter set to both manual and apply" do
        let(:filter_value) { %w[apply manual] }

        it { is_expected.to contain_exactly(apply_draft_trainee, draft_trainee) }
      end

      context "with record_source filter set to both dttp and apply" do
        let(:filter_value) { %w[apply dttp] }

        it { is_expected.to contain_exactly(apply_draft_trainee, dttp_trainee) }
      end

      context "with record_source filter set to both dttp and manual" do
        let(:filter_value) { %w[manual dttp] }

        it { is_expected.to contain_exactly(draft_trainee, dttp_trainee) }
      end

      context "with record_source filter set to both dttp, apply and manual" do
        let(:filter_value) { %w[apply dttp manual] }

        it { is_expected.to contain_exactly(apply_draft_trainee, dttp_trainee, draft_trainee) }
      end
    end

    context "with study_mode filter set to full time" do
      let!(:full_time_trainee) { create(:trainee, study_mode: "full_time", training_route: "early_years_salaried") }
      let(:filters) { { study_mode: %w[full_time] } }

      it { is_expected.to contain_exactly(full_time_trainee) }
    end

    context "with study_mode filter set to part time" do
      let!(:full_time_trainee) { create(:trainee, study_mode: "full_time", training_route: "early_years_salaried") }
      let!(:part_time_trainee) { create(:trainee, study_mode: "part_time", training_route: "early_years_salaried") }
      let(:filters) { { study_mode: %w[part_time] } }

      it { is_expected.to contain_exactly(part_time_trainee) }
    end

    context "with study_mode filter set to full time and part time" do
      let!(:full_time_trainee) { create(:trainee, study_mode: "full_time", training_route: "early_years_salaried") }
      let!(:part_time_trainee) { create(:trainee, study_mode: "part_time", training_route: "early_years_salaried") }
      let(:filters) { { study_mode: %w[full_time part_time] } }

      it { is_expected.to contain_exactly(draft_trainee, apply_draft_trainee, full_time_trainee, part_time_trainee) }
    end

    context "when courses are assesment only and study mode filter is part time" do
      let!(:full_time_trainee) { create(:trainee, study_mode: "full_time", training_route: "assessment_only") }
      let!(:part_time_trainee) { create(:trainee, study_mode: "part_time", training_route: "assessment_only") }
      let(:filters) { { study_mode: %w[part_time] } }

      it { is_expected.to be_empty }
    end

    describe "error is not raised" do
      let(:trigger) do
        # NOTE: forcing the subject to deserialise
        subject.count
      end

      let(:subject_name) { CourseSubjects::BIOLOGY }
      let!(:trainee_with_subject) { create(:trainee, provider_trainee_id: "bug", course_subject_one: subject_name) }
      let(:filters) { { subject: subject_name, text_search: "bug" } }

      it { expect { trigger } .not_to raise_error }
    end

    describe "not_withdrawn_before filter" do
      let!(:withdrawn_trainee_before_date) do
        create(:trainee, :withdrawn, withdrawal_date: Date.new(2023, 9, 1))
      end
      let!(:withdrawn_trainee_on_date) do
        create(:trainee, :withdrawn, withdrawal_date: Date.new(2023, 10, 11))
      end
      let!(:withdrawn_trainee_after_date) do
        create(:trainee, :withdrawn, withdrawal_date: Date.new(2023, 11, 1))
      end
      let!(:withdrawn_trainee_before_and_again_after_date) do
        trainee = create(:trainee, :withdrawn, withdrawal_date: Date.new(2023, 11, 1))
        create(:trainee_withdrawal, trainee: trainee, date: Date.new(2023, 9, 1))
        trainee
      end
      let!(:active_trainee) { create(:trainee) }

      let(:filters) { { not_withdrawn_before: Date.new(2023, 10, 11) } }

      it "excludes trainees withdrawn before the given date" do
        expect(subject).to contain_exactly(
          withdrawn_trainee_on_date,
          withdrawn_trainee_after_date,
          withdrawn_trainee_before_and_again_after_date,
          active_trainee,
        )
      end
    end
  end
end
