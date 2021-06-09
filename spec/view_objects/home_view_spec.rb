# frozen_string_literal: true

require "rails_helper"

describe HomeView do
  subject { described_class.new(trainees) }

  context "no trainees in award states" do
    let(:trainees) do
      trainee_id = create(:trainee, state: :draft).id
      Trainee.where(id: trainee_id)
    end

    it "labels award counts generically" do
      expect(subject.state_counts.symbolize_keys).to eq(
        awarded: 0,
        deferred: 0,
        draft: 1,
        recommended_for_award: 0,
        submitted_for_trn: 0,
        trn_received: 0,
        withdrawn: 0,
      )
    end
  end

  context "trainees only in eyts award states" do
    let(:trainees) do
      trainee_id = create(:trainee, training_route: :early_years_undergrad, state: :awarded).id
      Trainee.where(id: trainee_id)
    end

    it "labels award counts as eyts" do
      expect(subject.state_counts.symbolize_keys).to eq(
        deferred: 0,
        draft: 0,
        submitted_for_trn: 0,
        trn_received: 0,
        withdrawn: 0,
        eyts_awarded: 1,
        eyts_recommended: 0,
      )
    end
  end

  context "trainees only in qts award states" do
    let(:trainees) do
      trainee_id = create(:trainee, training_route: :assessment_only, state: :awarded).id
      Trainee.where(id: trainee_id)
    end

    it "labels award counts as qts" do
      expect(subject.state_counts.symbolize_keys).to eq(
        deferred: 0,
        draft: 0,
        submitted_for_trn: 0,
        trn_received: 0,
        withdrawn: 0,
        qts_awarded: 1,
        qts_recommended: 0,
      )
    end
  end

  context "trainees in qts and eyts award states" do
    let(:trainees) do
      trainee_ids = [
        create(:trainee, training_route: :assessment_only, state: :awarded).id,
        create(:trainee, training_route: :early_years_undergrad, state: :awarded).id,
      ]
      Trainee.where(id: trainee_ids)
    end

    it "labels award counts generically" do
      expect(subject.state_counts.symbolize_keys).to eq(
        deferred: 0,
        draft: 0,
        submitted_for_trn: 0,
        trn_received: 0,
        withdrawn: 0,
        awarded: 2,
        recommended_for_award: 0,
      )
    end
  end
end
