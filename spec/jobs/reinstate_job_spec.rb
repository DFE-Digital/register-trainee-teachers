# frozen_string_literal: true

require "rails_helper"

describe ReinstateJob do
  include ActiveJob::TestHelper

  let(:trainee) { create(:trainee, :deferred, trn: trn) }

  let(:contact_update_params) do
    {
      entity_id: trainee.dttp_id,
      entity_type: Dttp::UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
    }
  end

  let(:placement_assignment_update_params) do
    {
      entity_id: trainee.placement_assignment_dttp_id,
      entity_type: Dttp::UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
    }
  end

  let(:with_trn_param) { { status: DttpStatuses::YET_TO_COMPLETE_COURSE } }
  let(:without_trn_param) { { status: DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED } }

  let(:contact_update_params_with_trn) { contact_update_params.merge(with_trn_param) }
  let(:contact_update_params_without_trn) { contact_update_params.merge(without_trn_param) }
  let(:placement_assignment_update_params_with_trn) { placement_assignment_update_params.merge(with_trn_param) }
  let(:placement_assignment_update_params_without_trn) { placement_assignment_update_params.merge(without_trn_param) }

  subject { described_class.perform_now(trainee.id) }

  before do
    allow(Dttp::UpdateTraineeStatus).to receive(:call).with(contact_update_params_with_trn)
    allow(Dttp::UpdateTraineeStatus).to receive(:call).with(contact_update_params_without_trn)
    allow(Dttp::UpdateTraineeStatus).to receive(:call).with(placement_assignment_update_params_with_trn)
    allow(Dttp::UpdateTraineeStatus).to receive(:call).with(placement_assignment_update_params_without_trn)
    allow(Dttp::UpdateDormancy).to receive(:call).with(trainee: trainee)
  end

  context "with a trainee with a trn" do
    let(:trn) { "trn" }

    it "updates the contact status and the placement assignment status to 'Yet to complete course' in DTTP" do
      expect(Dttp::UpdateTraineeStatus).to receive(:call).with(contact_update_params_with_trn)
      expect(Dttp::UpdateTraineeStatus).to receive(:call).with(placement_assignment_update_params_with_trn)
      subject
    end
  end

  context "with a trainee without a trn" do
    let(:trn) { nil }

    it "updates the contact status and the placement assignment status to 'Prospective trainee - TREFNO requested' in DTTP" do
      expect(Dttp::UpdateTraineeStatus).to receive(:call).with(contact_update_params_without_trn)
      expect(Dttp::UpdateTraineeStatus).to receive(:call).with(placement_assignment_update_params_without_trn)
      subject
    end
  end
end
