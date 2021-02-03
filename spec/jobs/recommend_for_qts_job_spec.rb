# frozen_string_literal: true

require "rails_helper"

describe RecommendForQtsJob do
  include ActiveJob::TestHelper

  let(:trainee) { create(:trainee, :recommended_for_qts) }

  let(:expected_contact_params) do
    {
      status: DttpStatuses::STANDARDS_MET,
      entity_id: trainee.dttp_id,
      entity_type: :contact,
    }
  end

  let(:expected_placement_assignment_params) do
    {
      status: DttpStatuses::STANDARDS_MET,
      entity_id: trainee.placement_assignment_dttp_id,
      entity_type: :placement_assignment,
    }
  end

  before do
    allow(Dttp::RecommendForQTS).to receive(:call).with(trainee: trainee)
    allow(Dttp::UpdateTraineeStatus).to receive(:call).with(expected_contact_params)
    allow(Dttp::UpdateTraineeStatus).to receive(:call).with(expected_placement_assignment_params)
  end

  it "updates the contact and placement assignment status in DTTP" do
    expect(Dttp::UpdateTraineeStatus).to receive(:call).with(expected_contact_params)
    expect(Dttp::UpdateTraineeStatus).to receive(:call).with(expected_placement_assignment_params)
    described_class.perform_now(trainee.id)
  end
end
