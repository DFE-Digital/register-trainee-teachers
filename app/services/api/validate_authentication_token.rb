# frozen_string_literal: true

module Api
  class ValidateAuthenticationToken < BaseService
    attr_reader :auth_token

    def initialize(auth_token:)
      @auth_token = auth_token
    end

    def call
      auth_token.present? && auth_token.active? && provider&.kept?
    end

  private

    def provider
      @provider ||= auth_token&.provider
    end
  end
end
