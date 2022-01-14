# frozen_string_literal: true

class OrganisationContextPolicy
  attr_reader :user, :organisation

  def initialize(user, organisation)
    @user = user
    @organisation = organisation
  end

  def show?
    user.present? && user_belongs_to_organisation?
  end

  def index?
    user.present?
  end

private

  def user_belongs_to_organisation?
    return user.providers.include?(organisation) if organisation.is_a?(Provider)
    return user.lead_schools.include?(organisation) if organisation.is_a?(School)

    false
  end
end
