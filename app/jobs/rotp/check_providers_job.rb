# frozen_string_literal: true

module Rotp
  class CheckProvidersJob < ApplicationJob
    queue_as :default
    retry_on Rotp::Client::HttpError

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

    def build_message(checker)
      message = +""
      message << build_section("Accredited Providers",
                               matched: checker.accredited_matched,
                               missing_from_register: checker.accredited_missing_from_register,
                               missing_from_rotp: checker.accredited_missing_from_rotp)

      message << build_section("Training Partners (HEI/SCITT)",
                               matched: checker.training_partner_matched,
                               missing_from_register: checker.training_partner_missing_from_register,
                               missing_from_rotp: checker.training_partner_missing_from_rotp)

      message << build_section("Training Partners (School)",
                               matched: checker.school_matched,
                               missing_from_register: checker.school_missing_from_register,
                               missing_from_rotp: checker.school_missing_from_rotp)
    end

    def build_section(title, matched:, missing_from_register:, missing_from_rotp:)
      section = "**#{title}**\n"
      section << "Matched: #{matched.count}\n"
      section << "Not matched: #{missing_from_register.count + missing_from_rotp.count}\n\n"
      section << "In RoTP but not Register: #{missing_from_register.count}\n"
      append_missing_list(section, missing_from_register)
      section << "In Register but not RoTP: #{missing_from_rotp.count}\n"
      append_missing_list(section, missing_from_rotp)
      section << "\n"
    end

    def append_missing_list(message, missing_list)
      missing_list.each do |provider|
        identifier = provider["code"] || provider["urn"]
        message << "  - #{provider['operating_name']} (#{identifier})\n"
      end
      message << "\n" if missing_list.any?
    end
  end
end
