# frozen_string_literal: true

module Trainees
  class SetCohortJob < ApplicationJob
    def perform(trainee)
      return unless FeatureService.enabled?(:set_trainee_cohort)

      Trainees::SetCohort.call(trainee: trainee)
    end
  end
end
