# frozen_string_literal: true

module Dqt
  class RegisterForTrnJob < ApplicationJob
    include Sidekiq::Throttled::Job
    sidekiq_throttle({
      concurrency: { limit: 1 },
      threshold: { limit: 20, period: 1.minute },
    })

    sidekiq_options retry: 0
    queue_as :dqt

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)
      return if trainee.trn.present?

      trn_request = RegisterForTrn.call(trainee: trainee)
      RetrieveTrnJob.perform_later(trn_request) unless trn_request.failed?
    end
  end
end
