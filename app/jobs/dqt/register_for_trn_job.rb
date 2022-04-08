# frozen_string_literal: true

module Dqt
  class RegisterForTrnJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :default

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      if trainee.hesa_record?
        message = "Trainee id: #{trainee.id}, slug: #{trainee.slug} has been registered for TRN but is a HESA trainee"
        username = "Register Trainee Teachers: Job Failure"
        SlackNotifierService.call(message: message, username: username)
      else
        trn_request = RegisterForTrn.call(trainee: trainee)
        RetrieveTrnJob.perform_later(trn_request)
      end
    end
  end
end
