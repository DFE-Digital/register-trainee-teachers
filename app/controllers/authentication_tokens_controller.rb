# frozen_string_literal: true

class AuthenticationTokensController < ApplicationController
  before_action { require_feature_flag(:token_management) }

  def index
    @tokens = authorize(tokens).by_status_and_last_used_at
  end

private

  def tokens
    policy_scope(AuthenticationToken)
      .includes(:provider, :created_by, :revoked_by)
  end
end
