# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate

  def callback
    DfESignInUser.begin_session!(session, request.env["omniauth.auth"])

    if FeatureService.enabled?("allow_user_creation") && current_user.nil?
      @current_user = User.new(
        dttp_id: SecureRandom.uuid,
        provider: Provider.create_or_find_by(
          name: "DfE",
          dttp_id: SecureRandom.uuid,
          code: "000",
        ),
      )
    end

    if current_user
      DfESignInUsers::Update.call(user: current_user, dfe_sign_in_user: dfe_sign_in_user)

      if session[:redirect_back_to]
        redirect_to session[:redirect_back_to] && session.delete(:redirect_back_to)
      else
        redirect_to root_path
      end
    else
      DfESignInUser.end_session!(session)
      redirect_to sign_in_user_not_found_path
    end
  end

  def signout
    redirect_to root_path
  end
end
