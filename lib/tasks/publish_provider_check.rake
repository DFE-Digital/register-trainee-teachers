# frozen_string_literal: true

PUBLISH_PROVIDER_ENDPOINT = "https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2023/providers"

class PublishProviderChecker
  include ServicePattern

  def call
    next_link = PUBLISH_PROVIDER_ENDPOINT
    while next_link.present?
      response = HTTParty.get(next_link).parsed_response
      response["data"].map { |p| p["attributes"] }.each do |provider|
        if provider_matches?(provider)
          puts("Provider #{provider['code']} matches")
        elsif lead_school_matches?(provider)
          puts("Lead school #{provider['code']} matches")
        elsif lead_partner_matches?(provider)
          puts("Lead partner #{provider['code']} matches")
        else
          puts("No matching record for provider #{provider['code']}")
        end
      end
      next_link = response["links"]["next"]
    end
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

namespace :publish_providers do
  desc "Fetch the list of providers from the Publish service and compare with Register's providers"
  task compare: :environment do
    PublishProviderChecker.call
  end
end
