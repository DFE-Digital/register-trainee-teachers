# frozen_string_literal: true

module Rotp
  class CheckProvidersJob < ApplicationJob
    queue_as :default
    retry_on Rotp::Client::HttpError
    MAX_LISTED = 10

    def perform
      return false unless Rails.env.production? || Rails.env.productiondata?
 

      checker = Rotp::ProviderChecker.new
      download_url = generate_csv_download_url(checker)

      TeamsNotifierService.call(
        title: "RoTP Provider Checker Results [#{Rails.env}]",
        message: build_message(checker, download_url:),
        icon_emoji: checker.any_discrepancies? ? "🚨" : "✅",
      )
    end

  private

    def generate_csv_download_url(checker)
      csv = Rotp::ProviderCheckerCsvExport.call(checker)
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(csv),
        filename: "rotp_provider_check_#{Time.zone.today}.csv",
        content_type: "text/csv",
      )
      blob.url(expires_in: 7.days)
    end

    def build_message(checker, download_url:)
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

      message << "[Download full provider check CSV](#{download_url})"
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
      missing_list.first(MAX_LISTED).each do |provider|
        identifier = provider["code"] || provider["urn"]
        message << "  - #{provider['operating_name']} (#{identifier})\n"
      end

      remaining = missing_list.count - MAX_LISTED
      message << "  - ...and #{remaining} more\n" if remaining.positive?
      message << "\n" if missing_list.any?
    end
  end
end
