# frozen_string_literal: true

class AuthenticationTokensController < ApplicationController
  def index
    authorize(tokens)
  end

private

  def tokens
    @tokens ||= policy_scope(AuthenticationToken)
      .includes(:provider, :created_by, :revoked_by)
  end
end
