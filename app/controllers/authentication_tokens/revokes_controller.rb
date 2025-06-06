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
      @token ||= AuthenticationToken.find(params[:authentication_token_id])
    end
  end
end
