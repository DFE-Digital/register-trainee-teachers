# frozen_string_literal: true

class DiscardInactiveUsersJob < ApplicationJob
  queue_as :default

  def perform
    FindInactiveUsers.call.discard_all!
  end
end
