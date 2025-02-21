# frozen_string_literal: true

class OrganisationSwitcher::View < ViewComponent::Base
  include OrganisationHelper

  attr_reader :current_user

  def initialize(current_user:)
    @current_user = current_user
  end

  def render?
    current_user&.organisation.present?
  end

  def organisation_name
    current_user&.organisation&.name
  end

  def link_to_switch_organisation
    organisations_path
  end
end
