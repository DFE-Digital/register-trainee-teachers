# frozen_string_literal: true

module Trainees
  class UpdateSubmissionReadinessJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :default

    def perform(trainee)
      trainee.update(submission_ready: TrnSubmissionForm.new(trainee: trainee).valid?)
    end
  end
end
