# frozen_string_literal: true

module TeacherTrainingApi
  class CheckCoursesForMissingProvidersJob < ApplicationJob
    queue_as :default
    retry_on TeacherTrainingApi::Client::HttpError

    def perform(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
      return false unless Rails.env.production? || Rails.env.test?

      checker = TeacherTrainingApi::CheckCoursesForMissingProviders.call(
        recruitment_cycle_year:,
      )

      SlackNotifierService.call(
        message: checker[:message],
        icon_emoji: checker[:courses_with_missing_provider_count].zero? ? ":inky-the-octopus:" : ":alert:",
        username: "Register Trainee Teachers: Job Failure",
      )
    end
  end
end
