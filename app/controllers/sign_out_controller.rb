# frozen_string_literal: true

class SignOutController < ApplicationController
  skip_before_action :check_organisation_context_is_set

  def index
    DfESignInUser.end_session!(session)
    redirect_to(dfe_sign_in_user.logout_url, allow_other_host: true)
  end
end
