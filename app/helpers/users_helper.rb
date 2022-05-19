# frozen_string_literal: true

module UsersHelper
  def lead_school_user?
    defined?(current_user) && current_user&.lead_school?
  end

  def can_view_drafts?
    defined?(current_user).present? && current_user.present? && UserPolicy.new(current_user, nil).drafts?
  end
end
