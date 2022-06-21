# frozen_string_literal: true

module Trainees
  class SetAcademicCyclesJob < ApplicationJob
    def perform(trainee)
      return unless FeatureService.enabled?(:set_trainee_academic_cycles)

      trainee = Trainees::SetAcademicCycles.call(trainee: trainee)
      trainee.save!
    end
  end
end
