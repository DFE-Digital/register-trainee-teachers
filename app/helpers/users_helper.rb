# frozen_string_literal: true

module UsersHelper
  def lead_school_user?
    defined?(current_user) && current_user&.lead_school?
  end
end
