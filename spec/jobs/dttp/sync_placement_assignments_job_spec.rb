# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe SyncPlacementAssignmentsJob do
    include ActiveJob::TestHelper

    let(:placement_assignment_one_hash) { create(:api_placement_assignment) }
    let(:placement_assignment_two_hash) { create(:api_placement_assignment) }
    let(:next_page_url) { "https://some-url.com" }

    let(:placement_assignment_list) do
      {
        items: [placement_assignment_one_hash, placement_assignment_two_hash],
        meta: { next_page_url: next_page_url },
      }
    end

    subject { described_class.perform_now }

    before do
      enable_features(:sync_trainees_from_dttp)
      allow(RetrievePlacementAssignments).to receive(:call) { placement_assignment_list }
    end

    it "enqueues job with the next_page_url" do
      expect {
        subject
      }.to have_enqueued_job(described_class).with("https://some-url.com")
    end

    context "when the Dttp:PlacementAssignment is not in register" do
      it "creates a Dttp::PlacementAssignment record for each unique placement assignment" do
        expect {
          subject
        }.to change(Dttp::PlacementAssignment, :count).by(2)
      end
    end

    context "when a Dttp::PlacementAssignment exists" do
      let(:dttp_placement_assignment) { create(:dttp_placement_assignment, dttp_id: placement_assignment_one_hash["dfe_placementassignmentid"]) }

      before do
        dttp_placement_assignment
      end

      it "updates the existing record" do
        subject
        expect(dttp_placement_assignment.reload.response).to eq(placement_assignment_one_hash)
      end
    end

    context "when next_page_url is not available" do
      let(:next_page_url) { nil }

      it "does not enqueue any further jobs" do
        expect {
          subject
        }.not_to have_enqueued_job(described_class)
      end
    end
  end
end
