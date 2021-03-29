# frozen_string_literal: true

require "rails_helper"

describe RegisterForTrnJob do
  let(:trainee) { create(:trainee, dttp_id: dttp_id, placement_assignment_dttp_id: placement_assignment_dttp_id) }
  let(:dttp_id) { SecureRandom.uuid }
  let(:placement_assignment_dttp_id) { SecureRandom.uuid }
  let(:creator_dttp_id) { SecureRandom.uuid }

  before do
    allow(Dttp::RegisterForTrn).to receive(:call)
  end

  describe "#perform_now" do
    subject { described_class.perform_now(trainee, creator_dttp_id) }

    it "registers the trainee" do
      expect(Dttp::RegisterForTrn).to receive(:call).with(trainee: trainee, trainee_creator_dttp_id: creator_dttp_id)
      subject
    end

    it "queues a job to update the contact status" do
      expect { subject }.to have_enqueued_job(ChangeTraineeStatusJob).with(
        dttp_id,
        DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
        Dttp::UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
      )
    end

    it "queues a job to update the contact status" do
      expect { subject }.to have_enqueued_job(ChangeTraineeStatusJob).with(
        placement_assignment_dttp_id,
        DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
        Dttp::UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
      )
    end
  end
end
