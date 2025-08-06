# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe CheckCoursesForMissingProvidersJob do
    include ActiveJob::TestHelper

    let(:recruitment_cycle_year) { Settings.current_recruitment_cycle_year }
    let(:provider) { create(:provider) }
    let(:discarded_provider) { create(:provider, discarded_at: 1.day.ago, code: "A002") }

    before do
      create(:course, recruitment_cycle_year:, provider:)
      create(:course, recruitment_cycle_year: recruitment_cycle_year, provider: discarded_provider)
      create(:course, recruitment_cycle_year: recruitment_cycle_year, accredited_body_code: "A003")

      allow(SlackNotifierService).to receive(:call).and_return(true)
    end

    it "runs a job to check imported courses for missing providers" do
      Timecop.freeze do
        described_class.perform_now(recruitment_cycle_year:)
        expect(SlackNotifierService).to have_received(:call).with(
          {
            icon_emoji: ":alert:",
            message: "[#{Rails.env}] Course Provider Checker Results #{Time.zone.now.to_fs(:govuk_date_and_time)} for #{recruitment_cycle_year}:\n2 courses with a missing provider for recruitment cycle year.\nMissing provider codes: A002, A003.",
            username: "Register Trainee Teachers: Job Failure",
          },
        )
      end
    end
  end
end
