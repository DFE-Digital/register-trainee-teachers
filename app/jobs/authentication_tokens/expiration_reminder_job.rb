# frozen_string_literal: true

module AuthenticationTokens
  class ExpirationReminderJob < ApplicationJob
    def perform
      AuthenticationToken.active.where(expires_at: reminder_dates).find_each do |token|
        ExpirationReminderMailer.generate(authentication_token: token).deliver_later
      end
    end

  private

    def reminder_dates
      [1.day, 1.week, 1.month].map { |period| Date.current + period }
    end
  end
end
