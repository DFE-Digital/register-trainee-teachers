# frozen_string_literal: true

class MagicController < ApplicationController
  skip_before_action :authenticate

  def index
    unless FeatureService.enabled?(:dfe_sign_in_fallback)
      redirect_to sign_in_path
    end
  end

  def sign_in_by_email
    render_not_found and return unless FeatureService.enabled?(:dfe_sign_in_fallback)

    user = User.find_by(email: params.dig(:user, :email).downcase.strip)
    if user&.dfe_sign_in_uid.present?
      magic_link_token = user.create_magic_link_token!
      MagicEmailMailer.magic_email(user: user, token: magic_link_token).deliver_later
    end

    redirect_to sign_in_check_email_path
  end

  def check_your_email; end

  def authenticate_with_token
    redirect_to action: :index and return unless FeatureService.enabled?(:dfe_sign_in_fallback)

    user = User.authenticate!(params.fetch(:token))

    render_not_found and return unless user

    # Equivalent to calling DfESignInUser.begin_session!
    session["dfe_sign_in_user"] = {
      "email" => user.email,
      "dfe_sign_in_uid" => user.dfe_sign_in_uid,
      "first_name" => user.first_name,
      "last_name" => user.last_name,
      "last_active_at" => Time.zone.now,
    }

    user.update!(last_signed_in_at: Time.zone.now)

    redirect_to trainees_path
  end
end
