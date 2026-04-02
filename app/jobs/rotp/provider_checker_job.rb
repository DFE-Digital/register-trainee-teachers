# frozen_string_literal: true

module Rotp
  class ProviderCheckerJob < ApplicationJob
    queue_as :default
    retry_on Rotp::Client::HttpError

    MAX_MISSING_TO_DISPLAY = 10

    # Runs the provider comparison and posts a summary to Teams.
    # Production-only to avoid noise from dev/review environments.
    def perform
      return false unless Rails.env.production?

      checker = Rotp::ProviderChecker.new

      TeamsNotifierService.call(
        title: "RoTP Provider Checker Results [#{Rails.env}]",
        message: build_message(checker),
        icon_emoji: checker.any_discrepancies? ? "🚨" : "✅",
      )
    end

  private

    # Formats an Adaptive Card-compatible markdown summary for the Teams message.
    def build_message(checker)
      message = +"**Accredited Providers**\n"
      message << "Matched: #{checker.accredited_matched.count}\n"
      message << "In RoTP but not Register: #{checker.accredited_missing_from_register.count}\n"
      append_missing_list(message, checker.accredited_missing_from_register)
      message << "In Register but not RoTP: #{checker.accredited_missing_from_rotp.count}\n"
      append_missing_list(message, checker.accredited_missing_from_rotp)

      message << "\n**Training Partners (HEI/SCITT)**\n"
      message << "Matched: #{checker.training_partner_matched.count}\n"
      message << "In RoTP but not Register: #{checker.training_partner_missing_from_register.count}\n"
      append_missing_list(message, checker.training_partner_missing_from_register)
      message << "In Register but not RoTP: #{checker.training_partner_missing_from_rotp.count}\n"
      append_missing_list(message, checker.training_partner_missing_from_rotp)

      message << "\n**Not checked:** #{checker.skipped_schools.count} school training partners (no matching identifier available in RoTP API)\n"

      message
    end

    # Appends up to MAX_MISSING_TO_DISPLAY provider names to keep the message readable.
    def append_missing_list(message, missing_list)
      missing_list.first(MAX_MISSING_TO_DISPLAY).each do |provider|
        message << "  - #{provider['operating_name']} (#{provider['code']})\n"
      end
      message << "  - ... and #{missing_list.count - MAX_MISSING_TO_DISPLAY} more\n" if missing_list.count > MAX_MISSING_TO_DISPLAY
    end
  end
end
