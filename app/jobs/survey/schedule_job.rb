# frozen_string_literal: true

module Survey
  class ScheduleJob < ApplicationJob
    queue_as :default

    def perform(trainee:, event_type:)
      return unless FeatureService.enabled?(:qualtrics_survey)

      # Schedule the actual survey job for 7 days in the future
      SendJob.set(wait: 7.days).perform_later(trainee:, event_type:)
    end
  end
end
