# frozen_string_literal: true

module Dqt
  class WithdrawTraineeJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :dqt

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      WithdrawTrainee.call(trainee: trainee)
    end
  end
end
