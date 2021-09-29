# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe Filter do
    subject { described_class.call(trainees: trainees, filters: filters) }

    let!(:draft_trainee) { create(:trainee, :draft) }
    let!(:apply_draft_trainee) { create(:trainee, :with_apply_application) }
    let(:filters) { nil }
    let(:trainees) { Trainee.all }

    it { is_expected.to match_array(trainees) }

    context "empty trainee exists" do
      let!(:empty_trainee) do
        Trainee.create(provider_id: draft_trainee.provider.id,
                       training_route: TRAINING_ROUTE_ENUMS[:assessment_only])
      end

      it { is_expected.not_to include(empty_trainee) }
    end

    context "with training_route filter" do
      let!(:provider_led_postgrad_trainee) { create(:trainee, :provider_led_postgrad) }
      let(:filters) { { training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad] } }

      it { is_expected.to eq([provider_led_postgrad_trainee]) }
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

    context "with state filter" do
      let!(:submitted_for_trn_trainee) { create(:trainee, :submitted_for_trn) }
      let!(:qts_awarded_trainee) { create(:trainee, :qts_awarded) }
      let!(:eyts_awarded_trainee) { create(:trainee, :eyts_awarded) }

      context "with trn_submitted, qts_awarded" do
        let(:filters) { { state: %w[submitted_for_trn qts_awarded] } }

        it { is_expected.to contain_exactly(submitted_for_trn_trainee, qts_awarded_trainee) }
      end

      context "with only draft trainees" do
        let(:filters) { { state: %w[draft] } }

        it { is_expected.to contain_exactly(draft_trainee, apply_draft_trainee) }
      end
    end

    context "with subject filter" do
      let(:subject_name) { CourseSubjects::BIOLOGY }
      let!(:trainee_with_subject) { create(:trainee, course_subject_one: subject_name) }
      let(:filters) { { subject: subject_name } }

      it { is_expected.to eq([trainee_with_subject]) }
    end

    context "with text_search filter" do
      let!(:named_trainee) { create(:trainee, first_names: "Boaty McBoatface") }
      let(:filters) { { text_search: "Boaty" } }

      it { is_expected.to eq([named_trainee]) }
    end

    context "with record_source filter set to apply" do
      let(:filters) { { record_source: %w[apply] } }

      it { is_expected.to contain_exactly(apply_draft_trainee) }
    end

    context "with record_source filter set to manual" do
      let(:filters) { { record_source: %w[manual] } }

      it { is_expected.to contain_exactly(draft_trainee) }
    end

    context "with record_source filter set to both manual and apply" do
      let(:filters) { { record_source: %w[apply manual] } }

      it { is_expected.to contain_exactly(apply_draft_trainee, draft_trainee) }
    end
  end
end
