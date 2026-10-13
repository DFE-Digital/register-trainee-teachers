# frozen_string_literal: true

module Survey
  class SendJob < ApplicationJob
    queue_as :default

    retry_on StandardError, wait: :polynomially_longer, attempts: 4

    def perform(trainee:, event_type:)
      return unless FeatureService.enabled?(:qualtrics_survey) && trainee.email.present?

      case event_type
      when :withdraw
        Withdraw.call(trainee:)
      when :award
        Award.call(trainee:)
      end
    end
  end
end
