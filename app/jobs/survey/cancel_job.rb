# frozen_string_literal: true

module Survey
  class CancelJob < ApplicationJob
    queue_as :default

    def perform(trainee:)
      nil unless FeatureService.enabled?(:qualtrics_survey)

      # TODO: Implement Qualtrics API call to cancel scheduled distributions
      # This will require:
      # 1. Querying for distributions with this trainee's email
      # 2. Filtering for distributions that haven't been sent yet
      # 3. Canceling those distributions
    end
  end
end
