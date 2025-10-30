# frozen_string_literal: true

module AuthenticationTokens
  module Manage
    class View < ApplicationComponent
      include Pundit::Authorization

      attr_reader :current_user

      def initialize(current_user = Current.user)
        @current_user = current_user
      end
    end
  end
end
