# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate

  def callback
    DfESignInUser.begin_session!(session, request.env["omniauth.auth"])

    if FeatureService.enabled?("allow_user_creation") && current_user.nil?
      @current_user = User.new(
        provider: Provider.create_or_find_by(name: "DfE"),
      )
    end

    if current_user
      DfESignInUsers::Update.call(user: current_user, dfe_sign_in_user: dfe_sign_in_user)

      redirect_to trainees_path
    else
      DfESignInUser.end_session!(session)
      redirect_to sign_in_path
    end
  end

  def signout
    redirect_to root_path
  end
end
