# frozen_string_literal: true

module AuthenticationTokens
  module Manage
    class View < ApplicationComponent
      include Pundit::Authorization

      attr_reader :current_user

      def initialize(current_user:)
        @current_user = current_user
      end

      def can_generate_new_token?
        policy(AuthenticationToken.new).create?
      end
    end
  end
end
