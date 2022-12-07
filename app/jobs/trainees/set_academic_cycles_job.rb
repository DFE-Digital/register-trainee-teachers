# frozen_string_literal: true

module Trainees
  class SetAcademicCyclesJob < ApplicationJob
    def perform(trainee)
      return unless trainee.persisted? # Trainees can be deleted before this job runs

      trainee = Trainees::SetAcademicCycles.call(trainee:)
      trainee.save!
    end
  end
end
