# frozen_string_literal: true

class DeferJob < ApplicationJob
  queue_as :default
  retry_on Dttp::Defer::Error

  def perform(trainee_id)
    Dttp::Defer.call(trainee: Trainee.find(trainee_id))
  end
end
