# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe CheckCoursesForMissingProvidersJob do
    include ActiveJob::TestHelper

    let(:recruitment_cycle_year) { Settings.current_recruitment_cycle_year }
    let(:provider) { create(:provider) }

    before do
      create(:course, recruitment_cycle_year:, provider:)
      create(:course, recruitment_cycle_year: recruitment_cycle_year, accredited_body_code: "A002")
      create(:course, recruitment_cycle_year: recruitment_cycle_year, accredited_body_code: "A003")

      allow(SlackNotifierService).to receive(:call).and_return(true)
    end

    it "runs a job to check imported courses for missing providers" do
      described_class.perform_now(recruitment_cycle_year:)
      expect(SlackNotifierService).to have_received(:call).with(
        {
          icon_emoji: ":alert:",
          message: "There are 2 courses with missing providers for recruitment cycle year #{recruitment_cycle_year}. The missing provider codes are A002, A003.",
          username: "Register Trainee Teachers: Job Failure",
        }
      )
    end
  end
end
