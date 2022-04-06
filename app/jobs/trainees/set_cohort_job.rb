# frozen_string_literal: true

module Trainees
  class SetCohortJob < ApplicationJob
    def perform(trainee)
      Trainees::SetCohort.call(trainee: trainee)
    end
  end
end
