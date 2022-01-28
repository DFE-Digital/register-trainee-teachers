# frozen_string_literal: true

class UserWithOrganisationContext < SimpleDelegator
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

    school_or_provider
  end

  def multiple_organisations?
    return false unless FeatureService.enabled?(:user_can_have_multiple_organisations)

    (user.lead_schools + user.providers).count > 1
  end

  def provider?
    organisation.is_a?(Provider)
  end

  def lead_school?
    organisation.is_a?(School)
  end

private

  attr_reader :session

  def organisation_class
    session[:current_organisation][:type] == "School" ? School : Provider
  end

  def organisation_id
    session[:current_organisation][:id]
  end

  def school_or_provider
    organisation_to_return = if organisation_class == Provider
                               user.providers.find_by(id: organisation_id)
                             else
                               user.lead_schools.find_by(id: organisation_id)
                             end
    organisation_to_return
  end

  def single_organisation
    user.lead_schools.first || user.providers.first
  end
end
