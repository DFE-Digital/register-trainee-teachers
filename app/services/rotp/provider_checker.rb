# frozen_string_literal: true

module Rotp
  class ProviderChecker
    MATCHABLE_PROVIDER_TYPES = %w[hei scitt].freeze

    attr_reader :accredited_matched,
                :accredited_missing_from_register,
                :accredited_missing_from_rotp,
                :training_partner_matched,
                :training_partner_missing_from_register,
                :training_partner_missing_from_rotp,
                :skipped_schools

    def initialize
      @accredited_matched = []
      @accredited_missing_from_register = []
      @accredited_missing_from_rotp = []
      @training_partner_matched = []
      @training_partner_missing_from_register = []
      @training_partner_missing_from_rotp = []
      @skipped_schools = []

      rotp_providers = fetch_rotp_providers
      compare_accredited_providers(rotp_providers)
      compare_training_partners(rotp_providers)
    end

    def any_discrepancies?
      accredited_missing_from_register.any? ||
        accredited_missing_from_rotp.any? ||
        training_partner_missing_from_register.any? ||
        training_partner_missing_from_rotp.any?
    end

  private

    def fetch_rotp_providers
      Rotp::Providers.list
    end

    def compare_accredited_providers(rotp_providers)
      rotp_accredited = rotp_providers.select { |p| p["accreditation_status"] == "accredited" }
      rotp_codes = rotp_accredited.map { |p| p["code"] }.compact.to_set

      register_providers = Provider.kept.where(accredited: true)
      register_codes = register_providers.pluck(:code).compact.to_set

      rotp_accredited.each do |rotp_provider|
        code = rotp_provider["code"]
        if register_codes.include?(code)
          @accredited_matched << rotp_provider
        else
          @accredited_missing_from_register << rotp_provider
        end
      end

      register_providers.find_each do |provider|
        next if provider.code.blank?

        unless rotp_codes.include?(provider.code)
          @accredited_missing_from_rotp << { "operating_name" => provider.name, "code" => provider.code }
        end
      end
    end

    def compare_training_partners(rotp_providers)
      rotp_unaccredited = rotp_providers.select do |p|
        p["accreditation_status"] == "unaccredited" && p["provider_type"].in?(MATCHABLE_PROVIDER_TYPES)
      end

      @skipped_schools = rotp_providers.select do |p|
        p["accreditation_status"] == "unaccredited" && !p["provider_type"].in?(MATCHABLE_PROVIDER_TYPES)
      end

      rotp_codes = rotp_unaccredited.map { |p| p["code"] }.compact.to_set

      register_tps = TrainingPartner.kept.where.not(provider_id: nil).includes(:provider)
      register_codes = register_tps.filter_map { |tp| tp.provider&.code }.to_set

      rotp_unaccredited.each do |rotp_provider|
        code = rotp_provider["code"]
        if register_codes.include?(code)
          @training_partner_matched << rotp_provider
        else
          @training_partner_missing_from_register << rotp_provider
        end
      end

      register_tps.find_each do |tp|
        code = tp.provider&.code
        next if code.blank?

        unless rotp_codes.include?(code)
          @training_partner_missing_from_rotp << { "operating_name" => tp.name, "code" => code }
        end
      end
    end
  end
end
