# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe CheckConsistencyJob do
    let(:a_time) { Time.zone.now }
    let(:a_time_before) { a_time - 1.day }
    let(:a_time_after) { a_time + 1.day }
    let(:dttp_id) { SecureRandom.uuid }
    let(:placement_assignment_dttp_id) { SecureRandom.uuid }
    let(:trainee) { create(:trainee, dttp_id: dttp_id, placement_assignment_dttp_id: placement_assignment_dttp_id) }
    let(:consistency_check) do
      create(:consistency_check, trainee: trainee, contact_last_updated_at: a_time, placement_assignment_last_updated_at: a_time)
    end

    subject { described_class.perform_now(consistency_check.id) }

    context "contact updated on DTTP since the check was last created" do
      before do
        allow(Contacts::Fetch).to receive(:call)
          .with(dttp_id: dttp_id).and_return(OpenStruct.new(updated_at: a_time_after.to_s))
        allow(PlacementAssignments::Fetch).to receive(:call)
          .with(dttp_id: placement_assignment_dttp_id).and_return(OpenStruct.new(updated_at: a_time.to_s))
      end

      it "notifies slack of the conflict" do
        expect_slack_to_be_notified
        subject
      end
    end

    context "placement assignment updated on DTTP since the check was last created" do
      before do
        allow(Contacts::Fetch).to receive(:call)
          .with(dttp_id: dttp_id).and_return(OpenStruct.new(updated_at: a_time.to_s))
        allow(PlacementAssignments::Fetch).to receive(:call)
          .with(dttp_id: placement_assignment_dttp_id).and_return(OpenStruct.new(updated_at: a_time_after.to_s))
      end

      it "notifies slack of the conflict" do
        expect_slack_to_be_notified
        subject
      end
    end

    context "nothing has been updated" do
      before do
        allow(Contacts::Fetch).to receive(:call)
          .with(dttp_id: dttp_id).and_return(OpenStruct.new(updated_at: a_time.to_s))
        allow(PlacementAssignments::Fetch).to receive(:call)
          .with(dttp_id: placement_assignment_dttp_id).and_return(OpenStruct.new(updated_at: a_time.to_s))
      end

      it "does not notify slack" do
        expect_slack_not_to_be_notified
        subject
      end
    end

    def expect_slack_to_be_notified
      expect(SlackNotifierService).to receive(:call).with(
        message: "<https://localhost:5000/trainees/#{trainee.slug}|Trainee #{trainee.id} has been updated in DTTP>",
        username: "DTTP Conflict Error",
      )
    end

    def expect_slack_not_to_be_notified
      expect(SlackNotifierService).not_to receive(:call)
    end
  end
end
