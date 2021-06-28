# frozen_string_literal: true

module Dttp
  class RunConsistencyChecksJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      return unless FeatureService.enabled?("run_consistency_check_job") && ConsistencyCheck.any?

      ConsistencyCheck.all.each do |consistency_check|
        CheckConsistencyJob.perform_later(consistency_check.id)
      end
    end
  end
end
