# frozen_string_literal: true

class AuthenticationTokensController < ApplicationController
  before_action { require_feature_flag(:token_management) }

  PARAM_CONVERSION = {
    "expires_at(3i)" => "day",
    "expires_at(2i)" => "month",
    "expires_at(1i)" => "year",
  }.freeze

  def index
    authorize(tokens)
  end

  def show
    authorize(AuthenticationToken.find(params[:id]))
  end

  def new
    authorize(AuthenticationToken)

    @token_form = AuthenticationTokenForm.new(current_user)
  end

  def create
    authorize(AuthenticationToken)

    @token_form = AuthenticationTokenForm.new(current_user, params: token_params)

    if @token_form.save!
      flash[:token] = @token_form.authentication_token.token
      redirect_to(authentication_token_path(@token_form.authentication_token))
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
    params.require(:authentication_token_form).permit(:name, *PARAM_CONVERSION.keys)
      .transform_keys do |key|
        PARAM_CONVERSION.keys.include?(key) ? PARAM_CONVERSION[key] : key
      end
  end
end
