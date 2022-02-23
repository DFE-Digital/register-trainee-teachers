# frozen_string_literal: true

module OrganisationHelper
  def show_organisation_link?
    defined?(current_user) && current_user.present? &&
      current_user.multiple_organisations? &&
      current_user.organisation.present?
  end

  def hide_draft_records?
    defined?(current_user) && current_user.present? &&
      current_user.lead_school?
  end
end
