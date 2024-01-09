# frozen_string_literal: true

module UsersHelper
  def lead_school_user?
    defined?(current_user) && current_user&.lead_school?
  end

  def can_view_drafts?
    defined?(current_user).present? && current_user.present? && UserPolicy.new(current_user, nil).drafts?
  end

  def can_view_reports?
    can_view_drafts?
  end

  def can_view_funding?
    FeatureService.enabled?("funding") && defined?(current_user) && !current_user&.system_admin
  end

  def can_view_upload_funding?
    FeatureService.enabled?("upload_funding") && defined?(current_user) && current_user&.system_admin
  end

  def can_bulk_update?
    defined?(current_user) && current_user&.organisation.is_a?(Provider)
  end

  def can_bulk_recommend?
    defined?(current_user).present? && current_user.present? && UserPolicy.new(current_user, nil).bulk_recommend?
  end
end
