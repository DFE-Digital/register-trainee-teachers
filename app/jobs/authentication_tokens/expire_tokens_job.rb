# frozen_string_literal: true

module AuthenticationTokens
  class ExpireTokensJob < ApplicationJob
    def perform
      AuthenticationToken.will_expire(Date.current).update_all(status: :expired)
    end
  end
end
