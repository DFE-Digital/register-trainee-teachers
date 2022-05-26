# frozen_string_literal: true

module Dqt
  class WithdrawTraineeJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :dqt

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      return unless trainee_updatable?(trainee)

      WithdrawTrainee.call(trainee: trainee)
    end

  private

    def trainee_updatable?(trainee)
      !trainee.hesa_record?
    end
  end
end
