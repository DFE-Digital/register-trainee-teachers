# frozen_string_literal: true

module TeacherTrainingApi
  class PublishProviderChecker
    include ServicePattern

    attr_reader :recruitment_cycle_year, :provider_matches, :lead_partner_matches, :missing_accredited, :missing_unaccredited

    def initialize(recruitment_cycle_year:)
      @recruitment_cycle_year = recruitment_cycle_year
      @provider_matches = []
      @lead_partner_matches = []
      @missing_accredited = []
      @missing_unaccredited = []
    end

    def call
      next_link = publish_provider_endpoint
      while next_link.present?
        response = TeacherTrainingApi::Client::Request.get(next_link).parsed_response
        response["data"].map { |p| p["attributes"] }.each do |provider|
          if lead_partner_matches?(provider)
            lead_partner_matches << provider
          elsif provider_matches?(provider)
            provider_matches << provider
          elsif provider["accredited_body"]
            missing_accredited << provider
          else
            missing_unaccredited << provider
          end
        end
        next_link = response["links"]["next"]
      end

      self
    end

    def total_count
      lead_partner_matches.count +
        provider_matches.count +
        missing_accredited.count +
        missing_unaccredited.count
    end

    def missing
      missing_accredited + missing_unaccredited
    end

  private

    def publish_provider_endpoint
      "/recruitment_cycles/#{recruitment_cycle_year}/providers"
    end

    def provider_matches?(provider)
      Provider.find_by(code: provider["code"]).present? || Provider.find_by(ukprn: provider["ukprn"]).present?
    end

    def lead_partner_matches?(provider)
      LeadPartner.find_by(urn: provider["urn"]).present? || LeadPartner.find_by(ukprn: provider["ukprn"]).present?
    end
  end
end
