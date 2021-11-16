# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RecommendForAwardJob do
    include ActiveJob::TestHelper

    let(:trainee) { create(:trainee, :recommended_for_award) }

    let(:expected_contact_params) do
      {
        status: DttpStatuses::STANDARDS_MET,
        trainee: trainee,
        entity_type: :contact,
      }
    end

    let(:expected_placement_assignment_params) do
      {
        status: DttpStatuses::STANDARDS_MET,
        trainee: trainee,
        entity_type: :placement_assignment,
      }
    end

    before do
      enable_features(:persist_to_dttp)
      allow(Submissions::TrnValidator).to receive(:new).and_return(double(valid?: true))
      allow(RecommendForAward).to receive(:call).with(trainee: trainee)
      allow(UpdateTraineeStatus).to receive(:call).with(expected_contact_params)
      allow(UpdateTraineeStatus).to receive(:call).with(expected_placement_assignment_params)
    end

    it "updates the contact and placement assignment status in DTTP" do
      expect(UpdateTraineeStatus).to receive(:call).with(expected_contact_params)
      expect(UpdateTraineeStatus).to receive(:call).with(expected_placement_assignment_params)
      described_class.perform_now(trainee)
    end
  end
end
