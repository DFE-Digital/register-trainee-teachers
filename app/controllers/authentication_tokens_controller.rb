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
    @token, auth_token = AuthenticationToken.create_with_random_token(token_params)

    # TODO: Set the `created_by` attribute to the current user

    if @token.persisted?
      redirect_to(authentication_tokens_path)
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
    #TODO: Add the `name` to the strong params
    params.require(:authentication_token).permit(:expires_at)
  end
end
