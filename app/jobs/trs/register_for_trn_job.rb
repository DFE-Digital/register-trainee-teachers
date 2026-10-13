# frozen_string_literal: true

module Trs
  class RegisterForTrnJob < ApplicationJob
    retry_on StandardError, attempts: 1
    queue_as :trs

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_trs)
      return if trainee.trn.present?

      trn_request = RegisterForTrn.call(trainee:)
      RetrieveTrnJob.set(wait: 1.minute).perform_later(trn_request) if trn_request && !trn_request.failed?

      trn_request
    end
  end
end
