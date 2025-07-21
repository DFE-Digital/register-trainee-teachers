# frozen_string_literal: true

module TeacherTrainingApi
  class PublishProviderCheckerJob < ApplicationJob
    queue_as :default
    retry_on TeacherTrainingApi::Client::HttpError

    def perform
      return unless FeatureService.enabled?("publish_provider_checker")

      checker = TeacherTrainingApi::PublishProviderChecker.call(
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
      )

      message = "Publish Provider Checker Results #{Time.zone.now.to_fs(:govuk_date_and_time)} for #{checker.recruitment_cycle_year}:\n"
      message << "Matching lead schools:  #{checker.school_matches.count}\n"
      message << "Matching lead partners: #{checker.lead_partner_matches.count}\n"
      message << "Matching providers: #{checker.provider_matches.count}\n"
      message << "Missing providers: #{checker.missing.count}\n"
      message << "Total: #{checker.total_count}\n"

      SlackNotifierService.call(
        message: message,
        icon_emoji: checker.missing.count.zero? ? ":inky-the-octopus:" : ":alert:",
        username: "Register Trainee Teachers: Job Failure",
      )
    end
  end
end
