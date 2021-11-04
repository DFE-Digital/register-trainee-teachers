# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe QueueTraineeUpdatesJob do
    include ActiveJob::TestHelper

    context "with valid trainees" do
      let(:trainees) do
        create(:trainee, :submitted_for_trn)
        create(:trainee, :trn_received)
      end

      before do
        trainees
      end

      it "enqueues the UpdateTraineeJob" do
        described_class.perform_now

        Trainee.all.each do |trainee|
          expect(UpdateTraineeJob).to have_been_enqueued.with(trainee)
        end
      end
    end

    context "with invalid trainees" do
      before do
        create(:trainee, :draft)
        create(:trainee, :recommended_for_award)
        create(:trainee, :withdrawn)
        create(:trainee, :deferred)
        create(:trainee, :awarded)
        described_class::VALID_STATES.each do |state|
          create(:trainee, state.to_sym).update_columns(submission_ready: false)
        end
      end

      it "does not enqueue the UpdateTraineeJob" do
        described_class.perform_now

        Trainee.all.each do |trainee|
          expect(UpdateTraineeJob).not_to have_been_enqueued.with(trainee)
        end
      end
    end

    context "with trainees which have already been synced" do
      let(:trainee1) { create(:trainee, :trn_received) }
      let(:trainee2) { create(:trainee, :trn_received) }

      before do
        trainee1.update!(dttp_update_sha: trainee1.sha)
        trainee2.update!(dttp_update_sha: trainee2.sha)
      end

      it "does not enqueue the UpdateTraineeJob" do
        described_class.perform_now

        Trainee.all.each do |trainee|
          expect(UpdateTraineeJob).not_to have_been_enqueued.with(trainee)
        end
      end
    end
  end
end
