# frozen_string_literal: true

module Trainees
  class SetAcademicCyclesJob < ApplicationJob
    def perform(trainee)
      trainee = Trainees::SetAcademicCycles.call(trainee: trainee)
      trainee.save!
    end
  end
end
