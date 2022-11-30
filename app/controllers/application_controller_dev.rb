# frozen_string_literal: true

module ApplicationControllerDev
private

  # Current User set to first admin profile
  def current_user
    @current_user ||= begin
      user = User.where(system_admin: true).first
      UserWithOrganisationContext.new(user: user, session: session) if user.present?
    end
  end
end
