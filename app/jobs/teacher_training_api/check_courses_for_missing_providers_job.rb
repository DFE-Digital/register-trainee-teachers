# frozen_string_literal: true

module TeacherTrainingApi
  class CheckCoursesForMissingProvidersJob < ApplicationJob
    queue_as :default
    retry_on TeacherTrainingApi::Client::HttpError

    def perform(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
      return false unless Rails.env.production?

      checker = TeacherTrainingApi::CheckCoursesForMissingProviders.call(
        recruitment_cycle_year:,
      )

      TeamsNotifierService.call(
        title: "Course Provider Checker Results for #{recruitment_cycle_year} [#{Rails.env}]",
        message: checker[:message],
        icon_emoji: checker[:courses_with_missing_provider_count].to_i.positive? ? "🚨" : "✅",
      )
    end
  end
end
