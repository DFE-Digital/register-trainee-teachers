# frozen_string_literal: true

module Trainees
  class QueueCohortUpdatesJob < ApplicationJob
    def perform
      Trainee.current.or(Trainee.future).find_each do |trainee|
        SetCohortJob.perform_later(trainee)
      end
    end
  end
end
