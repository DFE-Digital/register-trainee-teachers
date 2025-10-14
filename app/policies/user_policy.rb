# frozen_string_literal: true

class UserPolicy < ProviderPolicy
  def permitted_attributes_for_create
    %i[first_name last_name email dttp_id]
  end

  def permitted_attributes_for_update
    [:email]
  end

  def drafts?
    user.system_admin? || user.provider?
  end

  def bulk_recommend?
    !user.system_admin? && !user.lead_partner?
  end

  def lead_partner_user?
    user.lead_partner?
  end

  def can_access_claims_reports?
    user.system_admin? && user.providers.empty? && user.lead_partners.empty?
  end

  def can_sign_off_performance_profile?
    user.provider? && user.organisation.performance_profile_awaiting_sign_off? && DetermineSignOffPeriod.call == :performance_period
  end

  alias_method :reports?, :drafts?
  alias_method :bulk_placement?, :bulk_recommend?
end
