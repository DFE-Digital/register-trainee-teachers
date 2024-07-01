# frozen_string_literal: true

class CopyProvidersToLeadPartnersService
  include ServicePattern

  attr_accessor :provider_ids

  def initialize(provider_ids:)
    self.provider_ids = provider_ids
  end

  def call
    Provider.where(id: provider_ids).find_each do |provider|
      lead_partner = LeadPartner.find_or_create_by!(ukprn: provider.ukprn, provider_id: provider.id) do |lp|
        lp.name = provider.name
        lp.record_type = LeadPartner::HEI
      end

      # Ensure lead_partner_users are up-to-date
      provider.users.each do |user|
        LeadPartnerUser.find_or_create_by!(lead_partner:, user:)
      end

      # Remove any LeadPartnerUser records that no longer correspond to the provider's users
      LeadPartnerUser.where(lead_partner:).where.not(user_id: provider.user_ids).destroy_all
    end
  end
end
