# frozen_string_literal: true

class PublishProviderChecker
  include ServicePattern

  PUBLISH_PROVIDER_ENDPOINT = "https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2024/providers"

  attr_reader :provider_matches, :lead_school_matches, :lead_partner_matches, :missing

  def initialize
    @provider_matches = []
    @lead_school_matches = []
    @lead_partner_matches = []
    @missing = []
  end

  def call
    next_link = PUBLISH_PROVIDER_ENDPOINT
    while next_link.present?
      response = HTTParty.get(next_link).parsed_response
      response["data"].map { |p| p["attributes"] }.each do |provider|
        if lead_school_matches?(provider)
          lead_school_matches << provider
        elsif lead_partner_matches?(provider)
          lead_partner_matches << provider
        elsif provider_matches?(provider)
          provider_matches << provider
        else
          missing << provider
        end
      end
      next_link = response["links"]["next"]
    end

    self
  end

  def total_count
    lead_school_matches.count + lead_partner_matches.count + provider_matches.count + missing.count
  end

private

  def provider_matches?(provider)
    Provider.find_by(code: provider["code"]).present?
  end

  def lead_school_matches?(provider)
    School.find_by(urn: provider["urn"]).present?
  end

  def lead_partner_matches?(provider)
    LeadPartner.find_by(urn: provider["urn"]).present?
  end
end

class PublishProviderReporter
  PUBLISH_PROVIDER_ENDPOINT = "https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2023/providers"

  attr_accessor :checker

  def initialize(checker)
    @checker = checker
  end

  def call
    output_report
  end

  def output_report
    puts("Publish providers that match a Register lead school")
    checker.lead_school_matches.each do |provider|
      puts("#{provider['name']} (#{provider['code']})")
    end

    puts("")
    puts("Publish providers that match a Register lead partner")
    checker.lead_partner_matches.each do |provider|
      puts("#{provider['name']} (#{provider['code']})")
    end

    puts("")
    puts("Publish providers that match a Register provider")
    checker.provider_matches.each do |provider|
      puts("#{provider['name']} (#{provider['code']})")
    end

    puts("")
    puts("Publish providers not found in Register")
    checker.missing.each do |provider|
      puts("#{provider['name']} (code: #{provider['code']}, urn: #{provider['urn']}, ukprn: #{provider['ukprn']}, type: #{provider['provider_type']})")
    end

    puts("")
    puts("Matching lead schools:  #{checker.lead_school_matches.count}")
    puts("Matching lead partners: #{checker.lead_partner_matches.count}")
    puts("Matching providers:     #{checker.provider_matches.count}")
    puts("Missing providers:      #{checker.missing.count}")
    puts("Total:                  #{checker.total_count}")
  end
end

namespace :publish_providers do
  desc "Fetch the list of providers from the Publish service and compare with Register's providers"
  task compare: :environment do
    PublishProviderReporter.new(PublishProviderChecker.call).call
  end
end
