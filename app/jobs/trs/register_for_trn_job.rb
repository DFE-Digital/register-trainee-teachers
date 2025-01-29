# frozen_string_literal: true

module Trs
  class RegisterForTrnJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :trs

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_trs)
      return if trainee.trn.present?

      RegisterForTrn.call(trainee:)
    end
  end
end
