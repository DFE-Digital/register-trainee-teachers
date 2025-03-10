# frozen_string_literal: true

module Survey
  class SendJob < ApplicationJob
    queue_as :default

    def perform(trainee:, event_type:)
      return unless FeatureService.enabled?(:qualtrics_survey)

      case event_type
      when :withdraw
        Withdraw.call(trainee:)
      when :award
        Award.call(trainee:)
      end
    end
  end
end
