# frozen_string_literal: true

class UserPolicy < ProviderPolicy
  def permitted_attributes_for_create
    %i[first_name last_name email dttp_id]
  end

  def permitted_attributes_for_update
    [:email]
  end

  def drafts?
    user.system_admin? || !user.lead_school?
  end

  def reports?
    user.system_admin? || !user.lead_school?
  end

  def bulk_recommend?
    !user.system_admin? && !user.lead_school?
  end
end
