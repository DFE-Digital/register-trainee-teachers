# frozen_string_literal: true

class SignOutController < ApplicationController
  skip_before_action :check_organisation_context_is_set

  def index
    DfESignInUser.end_session!(session)
    OtpSignInUser.end_session!(session)
    redirect_to(sign_in_user.logout_url(request), allow_other_host: true)
  end
end
