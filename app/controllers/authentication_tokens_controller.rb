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

private

  def tokens
    @tokens ||= policy_scope(AuthenticationToken)
      .includes(:provider, :created_by, :revoked_by)
      .by_status_and_last_used_at
  end
end
