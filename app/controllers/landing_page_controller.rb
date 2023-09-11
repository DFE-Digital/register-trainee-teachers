# frozen_string_literal: true

class LandingPageController < ApplicationController
  skip_before_action :authenticate

  def start
    session[:requested_path] = root_path
    if authenticated?
      if FeatureService.enabled?(:user_can_have_multiple_organisations) && organisation_not_set?
        redirect_to(organisations_path) && return
      end

      @trainees = policy_scope(Trainee.all)
      @home_view = HomeView.new(@trainees, current_user)
      render(:home)
    else
      render(:start)
    end
  end

private

  def organisation_not_set?
    current_user.organisation.nil? && !current_user.system_admin?
  end
end
