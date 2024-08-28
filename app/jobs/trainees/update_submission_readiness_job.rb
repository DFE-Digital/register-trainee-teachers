# frozen_string_literal: true

module Trainees
  class UpdateSubmissionReadinessJob < ApplicationJob
    queue_as :default

    def perform(trainee)
      trainee.send(:set_submission_ready)
      trainee.save
    end
  end
end
