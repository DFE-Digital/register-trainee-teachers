# frozen_string_literal: true

class SignOutController < ApplicationController
  skip_before_action :check_organisation_context_is_set

  def index
    DfESignInUser.end_session!(session)
    if FeatureService.enabled?(:dfe_sign_in_fallback)
      redirect_to(root_path)
    else
      redirect_to(dfe_sign_in_user.logout_url)
    end
  end
end
