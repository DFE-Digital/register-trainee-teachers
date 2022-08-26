# frozen_string_literal: true

module Dqt
  class RegisterForTrnJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :default

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)
      return if trainee.trn.present?

      trn_request = RegisterForTrn.call(trainee: trainee)
      RetrieveTrnJob.perform_later(trn_request)
    end
  end
end
