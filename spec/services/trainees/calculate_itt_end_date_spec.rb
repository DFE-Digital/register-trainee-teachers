# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CalculateIttEndDate do
    let(:trainee) { build(:trainee, :with_start_date, hesa_metadatum:, **trainee_attributes) }
    let(:hesa_metadatum) { build(:hesa_metadatum, study_length:, study_length_unit:) }
    let(:trainee_attributes) { {} }

    subject { described_class.call(trainee:) }

    context "study_length '1' and study_length_unit is 'years'" do
      let(:study_length) { 1 }
      let(:study_length_unit) { "years" }

      it { is_expected.to eq(trainee.trainee_start_date + 10.months) }
    end

    context "study_length and study_length_unit is nil" do
      let(:study_length) { nil }
      let(:study_length_unit) { nil }

      it { is_expected.to eq(trainee.trainee_start_date + 1.year) }

      context "trainee is part-time" do
        let(:trainee_attributes) { { study_mode: :part_time } }

        it { is_expected.to eq(trainee.trainee_start_date + 2.years) }
      end

      context "trainee has undergrade training route" do
        let(:trainee_attributes) { { training_route: UNDERGRAD_ROUTES.keys.sample } }

        it { is_expected.to eq(trainee.trainee_start_date + 3.years) }
      end
    end

    context "only compute actual end date - no adjustments" do
      let(:study_length) { 1 }
      let(:study_length_unit) { "years" }

      subject { described_class.call(trainee: trainee, actual: true) }

      it { is_expected.to eq(trainee.trainee_start_date + 1.year) }
    end
  end
end
