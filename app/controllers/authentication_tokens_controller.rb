# frozen_string_literal: true

class AuthenticationTokensController < ApplicationController
  before_action { require_feature_flag(:token_management) }

  def index
    authorize(tokens)
  end

  def new
    @token = AuthenticationToken.new
    authorize(@token)
  end

  def create
    authorize(AuthenticationToken, :create?)
    @token, token_string = AuthenticationToken.create_with_random_token(
      token_params.merge(
        provider: current_user.organisation,
        created_by: current_user,
      ),
    )

    if @token.persisted?
      flash[:token] = token_string
      redirect_to(authentication_token_path(@token))
    else
      render(:new)
    end
  end

private

  def tokens
    @tokens ||= policy_scope(AuthenticationToken)
      .includes(:provider, :created_by, :revoked_by)
      .by_status_and_last_used_at
  end

  def token_params
    params.require(:authentication_token).permit(:expires_at, :name)
  end
end
