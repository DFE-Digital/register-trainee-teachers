# frozen_string_literal: true

# This is prepended into `ApplicationController` if in development environment and the PERFORMANCE_TESTING env is present
# See `app/controllers/application_controller.rb` and  `app/services/feature_service.rb`
module ApplicationControllerDev
private

  # Current User set to first admin profile
  def current_user
    @current_user ||= begin
      user = User.where(system_admin: false).first
      UserWithOrganisationContext.new(user:, session:) if user.present?
    end
  end
end
