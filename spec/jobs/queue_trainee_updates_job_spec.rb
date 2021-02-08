# frozen_string_literal: true

require "rails_helper"

describe QueueTraineeUpdatesJob do
  include ActiveJob::TestHelper

  before do
    trainees
  end

  context "with valid trainees" do
    let(:trainees) do
      create(:trainee, :submitted_for_trn)
      create(:trainee, :trn_received)
    end

    it "enqueues the UpdateTraineeToDttpJob" do
      described_class.perform_now

      Trainee.all.each do |trainee|
        expect(UpdateTraineeToDttpJob).to have_been_enqueued.with(trainee)
      end
    end
  end

  context "with invalid trainees" do
    let(:trainees) do
      QueueTraineeUpdatesJob::INVALID_STATES.each do |state|
        create(:trainee, state.to_sym)
      end
    end

    it "does not enqueue the UpdateTraineeToDttpJob" do
      described_class.perform_now

      Trainee.all.each do |trainee|
        expect(UpdateTraineeToDttpJob).to_not have_been_enqueued.with(trainee)
      end
    end
  end
end
