# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe MapStateFromDttp do
    include SeedHelper
    let(:awaiting_qts_id) { Dttp::CodeSets::Statuses::MAPPING[DttpStatuses::AWAITING_QTS][:entity_id] }
    let(:deferred_id) { Dttp::CodeSets::Statuses::MAPPING[DttpStatuses::DEFERRED][:entity_id] }
    let(:qts_revoked_id) { Dttp::CodeSets::Statuses::MAPPING[DttpStatuses::QTS_REVOKED][:entity_id] }
    let(:standards_not_met_id) { Dttp::CodeSets::Statuses::MAPPING[DttpStatuses::STANDARDS_NOT_MET][:entity_id] }
    let(:awarded_qts_id) { Dttp::CodeSets::Statuses::MAPPING[DttpStatuses::AWARDED_QTS][:entity_id] }

    let(:api_trainee) { create(:api_trainee) }
    let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_traineestatusid_value: nil) }
    let(:placement_assignment) { create(:dttp_placement_assignment, response: api_placement_assignment) }
    let(:dttp_trainee) { create(:dttp_trainee, placement_assignments: [placement_assignment], api_trainee_hash: api_trainee) }

    subject { described_class.call(dttp_trainee: dttp_trainee) }

    context "when neither trainee nor placement_assignment have a status" do
      it "marks the trainee as non importable" do
        expect { subject }.to change(dttp_trainee, :state).to("non_importable_missing_state")
      end

      it { is_expected.to be_nil }
    end

    context "when the combination of statuses means the state is not determinable" do
      let(:api_trainee) { create(:api_trainee, _dfe_traineestatusid_value: awaiting_qts_id) }
      let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_traineestatusid_value: deferred_id) }

      it "marks the trainee as non importable" do
        expect { subject }.to change(dttp_trainee, :state).to("non_importable_missing_state")
      end

      it { is_expected.to be_nil }
    end

    context "the placement_assignment has a status but we don't have it in Register" do
      let(:api_trainee) { create(:api_trainee, _dfe_traineestatusid_value: qts_revoked_id) }

      it "marks the trainee as non importable" do
        expect { subject }.to change(dttp_trainee, :state).to("non_importable_missing_state")
      end

      it { is_expected.to be_nil }
    end

    context "when the placement assignment status is DEFERRED but the trainee status is STANDARDS_NOT_MET" do
      let(:api_trainee) { create(:api_trainee, _dfe_traineestatusid_value: standards_not_met_id) }
      let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_traineestatusid_value: deferred_id) }

      it { is_expected.to eq("deferred") }
    end

    context "when there is a placement assignment state but no trainee state" do
      let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_traineestatusid_value: awarded_qts_id) }

      it { is_expected.to eq("awarded") }

      context "and it is AWAITING_QTS" do
        let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_traineestatusid_value: awaiting_qts_id) }

        it { is_expected.to eq("recommended_for_award") }
      end

      context "and it is STANDARDS_NOT_MET" do
        context "and they have a 'dateleft'" do
          let(:api_placement_assignment) { create(:api_placement_assignment, dfe_dateleft: Time.zone.today, _dfe_traineestatusid_value: "215af972-9e1b-e711-80c7-0050568902d3") }

          it { is_expected.to eq("withdrawn") }
        end

        context "and they don't have a dateleft" do
          let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_traineestatusid_value: "215af972-9e1b-e711-80c7-0050568902d3") }

          it { is_expected.to eq("trn_received") }
        end
      end
    end

    context "when there is a placement assignment state and a trainee state" do
      context "when there no mismatch" do
        let(:api_trainee) { create(:api_trainee, _dfe_traineestatusid_value: deferred_id) }
        let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_traineestatusid_value: deferred_id) }

        it { is_expected.to eq("deferred") }
      end

      context "when there is a mismatch" do
        let(:api_trainee) { create(:api_trainee, _dfe_traineestatusid_value: standards_not_met_id) }
        let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_traineestatusid_value: awarded_qts_id) }

        it "returns the 'most' progressed state" do
          expect(subject).to eq("awarded")
        end
      end
    end
  end
end
