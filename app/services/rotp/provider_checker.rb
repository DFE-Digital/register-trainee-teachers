# frozen_string_literal: true

module Rotp
  class ProviderChecker
    MATCHABLE_PROVIDER_TYPES = %w[hei scitt].freeze
    EXCLUDED_PROVIDER = { name: "DfE", code: "GP" }.freeze

    attr_reader :accredited_matched,
                :accredited_missing_from_register,
                :accredited_missing_from_rotp,
                :training_partner_matched,
                :training_partner_missing_from_register,
                :training_partner_missing_from_rotp,
                :school_matched,
                :school_missing_from_register,
                :school_missing_from_rotp

    def initialize
      @accredited_matched = []
      @accredited_missing_from_register = []
      @accredited_missing_from_rotp = []
      @training_partner_matched = []
      @training_partner_missing_from_register = []
      @training_partner_missing_from_rotp = []
      @school_matched = []
      @school_missing_from_register = []
      @school_missing_from_rotp = []

      rotp_providers = fetch_rotp_providers
      compare_accredited_providers(rotp_providers)
      compare_training_partners(rotp_providers)
      compare_school_partners(rotp_providers)
    end

    def any_discrepancies?
      accredited_missing_from_register.any? ||
        accredited_missing_from_rotp.any? ||
        training_partner_missing_from_register.any? ||
        training_partner_missing_from_rotp.any? ||
        school_missing_from_register.any? ||
        school_missing_from_rotp.any?
    end

  private

    def fetch_rotp_providers
      Rotp::Providers.list
    end

    def compare_accredited_providers(rotp_providers)
      rotp_accredited = rotp_providers.select { |p| p["accreditation_status"] == "accredited" }
      rotp_codes = rotp_accredited.map { |p| p["code"] }.compact.to_set

      register_scope = Provider.kept.where(accredited: true).where.not(EXCLUDED_PROVIDER).where.not(code: [nil, ""])
      register_codes = register_scope.pluck(:code).to_set

      rotp_accredited.each do |rotp_provider|
        code = rotp_provider["code"]
        if register_codes.include?(code)
          @accredited_matched << rotp_provider
        else
          @accredited_missing_from_register << rotp_provider
        end
      end

      register_scope.find_each do |provider|
        unless rotp_codes.include?(provider.code)
          @accredited_missing_from_rotp << { "operating_name" => provider.name, "code" => provider.code }
        end
      end
    end

    def compare_training_partners(rotp_providers)
      all_rotp_unaccredited = rotp_providers.select { |p| p["accreditation_status"] == "unaccredited" }

      rotp_matchable = all_rotp_unaccredited.select { |p| p["provider_type"].in?(MATCHABLE_PROVIDER_TYPES) }

      all_rotp_unaccredited_codes = all_rotp_unaccredited.map { |p| p["code"] }.compact.to_set

      register_tps = TrainingPartner.kept.where.not(provider_id: nil).includes(:provider)
      register_codes = register_tps.filter_map { |tp| tp.provider&.code }.to_set

      rotp_matchable.each do |rotp_provider|
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

        unless all_rotp_unaccredited_codes.include?(code)
          @training_partner_missing_from_rotp << { "operating_name" => tp.name, "code" => code }
        end
      end
    end

    def compare_school_partners(rotp_providers)
      rotp_schools = rotp_providers.select { |p| p["accreditation_status"] == "unaccredited" && !p["provider_type"].in?(MATCHABLE_PROVIDER_TYPES) }
      rotp_urns = rotp_schools.map { |p| p["urn"] }.compact.to_set

      register_schools = TrainingPartner.kept.where(record_type: "school").where.not(urn: [nil, ""])
      register_urns = register_schools.pluck(:urn).to_set

      rotp_schools.each do |rotp_provider|
        urn = rotp_provider["urn"]
        if urn.present? && register_urns.include?(urn)
          @school_matched << rotp_provider
        else
          @school_missing_from_register << rotp_provider
        end
      end

      register_schools.find_each do |tp|
        unless rotp_urns.include?(tp.urn)
          @school_missing_from_rotp << { "operating_name" => tp.name, "urn" => tp.urn }
        end
      end
    end
  end
end
