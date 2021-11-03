# frozen_string_literal: true

module Dttp
  class QueueTraineeUpdatesJob < ApplicationJob
    queue_as :dttp

    VALID_STATES = %w[
      submitted_for_trn
      trn_received
    ].freeze

    def perform
      trainees = fetch_trainees

      return if trainees.blank?

      trainees.each do |trainee|
        next if trainee_already_synced?(trainee)

        UpdateTraineeJob.perform_later(trainee)
      end
    end

  private

    def fetch_trainees
      Trainee.where(state: VALID_STATES, submission_ready: true)
    end

    def trainee_already_synced?(trainee)
      trainee.sha == trainee.dttp_update_sha.presence
    end
  end
end
