# frozen_string_literal: true

module Dqt
  class RegisterForTrnJob < Dqt::BaseJob
    retry_on StandardError, attempts: 0
    queue_as :dqt

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)
      return if trainee.trn.present?

      trn_request = RegisterForTrn.call(trainee:)
      RetrieveTrnJob.perform_later(trn_request) unless trn_request.failed?

      trn_request
    end
  end
end
