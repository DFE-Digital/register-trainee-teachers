# frozen_string_literal: true

require "rails_helper"

module Survey
  describe ScheduleJob do
    include ActiveJob::TestHelper

    let(:trainee) { create(:trainee) }
    let(:event_type) { :withdraw }

    context "when the qualtrics_survey feature is enabled", feature_qualtrics_survey: true do
      before do
        allow(SendJob).to receive(:set).and_return(SendJob)
        allow(SendJob).to receive(:perform_later)
      end

      it "schedules the SendJob to run in 7 days" do
        expect(SendJob).to receive(:set).with(wait: 7.days)
        expect(SendJob).to receive(:perform_later).with(trainee:, event_type:)

        described_class.perform_now(trainee:, event_type:)
      end
    end

    context "when the qualtrics_survey feature is disabled", feature_qualtrics_survey: false do
      before do
        allow(SendJob).to receive(:set)
        allow(SendJob).to receive(:perform_later)
      end

      it "does not schedule the SendJob" do
        expect(SendJob).not_to receive(:set)
        expect(SendJob).not_to receive(:perform_later)

        described_class.perform_now(trainee:, event_type:)
      end
    end
  end
end
