# frozen_string_literal: true

module AuthenticationTokens
  class RevokesController < ApplicationController
    def show
      authorize(token)
    end

    def update
      authorize(token)

      token.revoke!

      redirect_to(authentication_tokens_path)
    end

  private

    def token
      @token ||= policy_scope(AuthenticationToken).find(token_params)
    end

    def token_params
      params.require(:authentication_token_id)
    end
  end
end
