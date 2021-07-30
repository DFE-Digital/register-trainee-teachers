# frozen_string_literal: true

require "rails_helper"

describe HomeView do
  subject { described_class.new(trainees) }

  describe "#state_counts" do
    context "no trainees in award states" do
      let(:trainees) do
        trainee_id = create(:trainee, :draft).id
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
        trainee_id = create(:trainee, :early_years_undergrad, :awarded).id
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
        trainee_id = create(:trainee, :assessment_only, :awarded).id
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
          create(:trainee, :assessment_only, :awarded).id,
          create(:trainee, :early_years_undergrad, :awarded).id,
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

  describe "#registered_state_counts" do
    let(:trainees) { Trainee.all }

    it "returns just the state_counts relevant for registered trainees" do
      expect(subject.registered_state_counts.symbolize_keys).to eq(
        deferred: 0,
        submitted_for_trn: 0,
        trn_received: 0,
        withdrawn: 0,
        awarded: 0,
        recommended_for_award: 0,
      )
    end
  end

  describe "#registered_trainees_count" do
    let(:trainees) do
      trainee_ids = [
        create(:trainee, :draft).id,
        create(:trainee, :assessment_only, :awarded).id,
        create(:trainee, :early_years_undergrad, :awarded).id,
      ]
      Trainee.where(id: trainee_ids)
    end

    it "returns the number of trainees in registered states" do
      expect(subject.registered_trainees_count).to eq(2)
    end
  end

  describe "#draft_trainees_count" do
    let(:trainees) do
      trainee_ids = [
        create(:trainee, :draft).id,
        create(:trainee, :assessment_only, :awarded).id,
        create(:trainee, :early_years_undergrad, :awarded).id,
      ]
      Trainee.where(id: trainee_ids)
    end

    it "returns the number of trainees in draft states" do
      expect(subject.draft_trainees_count).to eq(1)
    end
  end

  describe "#draft_apply_trainees_count" do
    let(:trainees) do
      trainee_ids = [
        create(:trainee, :draft).id,
        create(:trainee, :draft, :with_apply_application).id,
        create(:trainee, :awarded, :with_apply_application).id,
      ]
      Trainee.where(id: trainee_ids)
    end

    it "returns the number of trainees in apply draft states" do
      expect(subject.draft_apply_trainees_count).to eq(1)
    end
  end
end
