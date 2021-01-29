# frozen_string_literal: true

class WithdrawJob < ApplicationJob
  queue_as :default
  retry_on Dttp::Withdraw::Error

  def perform(trainee_id)
    Dttp::Withdraw.call(trainee: Trainee.find(trainee_id))
  end
end
