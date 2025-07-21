# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe PublishProviderCheckerJob do
    include ActiveJob::TestHelper

    let(:recruitment_cycle_year) { Settings.current_recruitment_cycle_year }
    let(:result) { TeacherTrainingApi::PublishProviderChecker.send(:new, recruitment_cycle_year:) }

    before do
      allow(TeacherTrainingApi::PublishProviderChecker).to receive(:call).with(recruitment_cycle_year:).and_return(result)
      allow(SlackNotifierService).to receive(:call).and_return(true)

      described_class.perform_now
    end

    context "when the feature flag is turned off", feature_publish_provider_checker: false do
      it "does not call TTAPI or Slack" do
        expect(TeacherTrainingApi::PublishProviderChecker).not_to have_received(:call)
        expect(SlackNotifierService).not_to have_received(:call)
      end
    end

    context "when the feature flag is turned on", feature_publish_provider_checker: true do
      it "generates the correct message and sends it to Slack" do
        expect(TeacherTrainingApi::PublishProviderChecker).to have_received(:call)
        expect(SlackNotifierService).to have_received(:call)
      end
    end
  end
end
