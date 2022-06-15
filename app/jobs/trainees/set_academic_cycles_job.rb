# frozen_string_literal: true

module Trainees
  class SetAcademicCyclesJob < ApplicationJob
    def perform(trainee)
      return unless FeatureService.enabled?(:set_trainee_academic_cycles)

      Trainees::SetAcademicCycles.call(trainee: trainee)
    end
  end
end
