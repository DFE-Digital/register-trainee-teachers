# frozen_string_literal: true

class SignOutController < ApplicationController
  def index
    DfESignInUser.end_session!(session)
    redirect_to dfe_sign_in_user.logout_url
  end
end
