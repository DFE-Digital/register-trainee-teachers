# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe Filter do
    subject { described_class.call(trainees: trainees, filters: filters) }

    let!(:generic_trainee) { create(:trainee) }
    let(:filters) { nil }
    let(:trainees) { Trainee.all }

    it { is_expected.to eq(trainees) }

    context "with training_route filter" do
      let!(:provider_led_postgrad_trainee) { create(:trainee, :provider_led_postgrad) }
      let(:filters) { { training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad] } }

      it { is_expected.to eq([provider_led_postgrad_trainee]) }
    end

    context "with state filter" do
      let!(:submitted_for_trn_trainee) { create(:trainee, :submitted_for_trn) }
      let(:filters) { { state: "submitted_for_trn" } }

      it { is_expected.to eq([submitted_for_trn_trainee]) }
    end

    context "with subject filter" do
      let!(:trainee_with_subject) { create(:trainee, subject: Dttp::CodeSets::CourseSubjects::MAPPING.keys.first) }
      let(:filters) { { subject: "Art and design" } }

      it { is_expected.to eq([trainee_with_subject]) }
    end

    context "with text_search filter" do
      let!(:named_trainee) { create(:trainee, first_names: "Boaty McBoatface") }
      let(:filters) { { text_search: "Boaty" } }

      it { is_expected.to eq([named_trainee]) }
    end
  end
end
