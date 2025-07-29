# frozen_string_literal: true

module TeacherTrainingApi
  class PublishProviderCheckerJob < ApplicationJob
    queue_as :default
    retry_on TeacherTrainingApi::Client::HttpError

    MAX_MISSING_PROVIDERS_TO_DISPLAY = 50

    def perform
      return unless FeatureService.enabled?("publish_provider_checker")

      checker = TeacherTrainingApi::PublishProviderChecker.call(
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
      )

      message = "[#{Rails.env}] Publish Provider Checker Results #{Time.zone.now.to_fs(:govuk_date_and_time)} for #{checker.recruitment_cycle_year}:\n"
      message << "Matching lead partners: #{checker.lead_partner_matches.count}\n"
      message << "Matching providers: #{checker.provider_matches.count}\n"
      message << "Missing accredited providers: #{checker.missing_accredited.count}\n"
      output_missing_list(message, checker.missing_accredited)

      message << "Missing unaccredited providers: #{checker.missing_unaccredited.count}\n"
      output_missing_list(message, checker.missing_unaccredited)

      message << "Total: #{checker.total_count}\n"

      SlackNotifierService.call(
        message: message,
        icon_emoji: checker.missing.count.zero? ? ":inky-the-octopus:" : ":alert:",
        username: "Register Trainee Teachers: Job Failure",
      )
    end

  private

    def output_missing_list(message, missing_list)
      missing_list.first(MAX_MISSING_PROVIDERS_TO_DISPLAY).each do |provider|
        message << "  - #{format_provider_details(provider)}\n"
      end
      if missing_list.count > MAX_MISSING_PROVIDERS_TO_DISPLAY
        message << "  - ...\n"
      end
    end

    def format_provider_details(provider)
      "#{provider['name']} (#{provider['code']}), UKPRN #{provider['ukprn']}\n"
    end
  end
end
