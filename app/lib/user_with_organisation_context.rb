# frozen_string_literal: true

class UserWithOrganisationContext < SimpleDelegator
  include Bullet::SimpleDelegatorHelpers if Rails.env.local?

  attr_reader :user

  def initialize(user:, session:)
    __setobj__(user)
    @user = user
    @session = session
  end

  class << self
    def primary_key
      "id"
    end

    delegate :composite_primary_key?, :has_query_constraints?, to: :model

    def model
      User
    end
  end

  def is_a?(value)
    value == User
  end

  def class_name
    "User"
  end

  def organisation
    return single_organisation unless multiple_organisations?

    return if session[:current_organisation].blank?

    lead_partner_or_provider
  end

  def multiple_organisations?
    return false unless FeatureService.enabled?(:user_can_have_multiple_organisations)

    (user.lead_partners + user.providers).many?
  end

  def organisation?
    organisation.present?
  end

  def provider?
    organisation.is_a?(Provider)
  end

  def accredited_provider?
    provider? && organisation.accredited?
  end

  def lead_partner?
    organisation.is_a?(LeadPartner)
  end

  def no_organisation?
    return false unless FeatureService.enabled?(:user_can_have_multiple_organisations)

    user.providers.none? && user.lead_partners.none? && !user.system_admin?
  end

  def hei_provider?
    provider? && organisation.hei?
  end

  def accredited_hei_provider?
    accredited_provider? && organisation.hei?
  end

  # HEI Lead Partners are all previously-accredited Providers. They should be signed in as
  # their previously-accredited Provider in order to use bulk update trainee uploads.
  def accredited_hei_provider_or_hei_lead_partner?
    accredited_hei_provider? || LeadPartner.hei.find_by(provider: organisation).present?
  end

private

  attr_reader :session

  def organisation_type
    session[:current_organisation][:type]
  end

  def organisation_id
    session[:current_organisation][:id]
  end

  def lead_partner_or_provider
    @_lead_partner_or_provider ||= {
      "LeadPartner" => user.lead_partners.find_by(id: organisation_id),
      "Provider" => user.providers.find_by(id: organisation_id),
    }[organisation_type]
  end

  def single_organisation
    if user_only_has_lead_partner? &&
        !FeatureService.enabled?(:user_can_have_multiple_organisations)

      raise(Pundit::NotAuthorizedError)
    end

    user.providers.first || user.lead_partners.first
  end

  def user_only_has_lead_partner?
    !user.system_admin && user.providers.empty? && user.lead_partners.present?
  end
end
