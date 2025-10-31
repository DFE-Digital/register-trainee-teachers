# frozen_string_literal: true

module AuthenticationTokens
  module Manage
    class View < ApplicationComponent
      include Pundit::Authorization

      MAX_LIVE_TOKENS = 2

      attr_reader :current_user

      def initialize(tokens:, current_user:)
        @tokens = tokens
        @current_user = current_user
      end

      def can_generate_new_token?
        @tokens.active.count < MAX_LIVE_TOKENS
      end
    end
  end
end
