# frozen_string_literal: true

module Dttp
  class QueueTraineeUpdatesJob < ApplicationJob
    queue_as :dttp

    INVALID_STATES = %w[
      draft
      recommended_for_award
      withdrawn
      deferred
      awarded
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
      Trainee.where.not(state: INVALID_STATES)
    end

    def trainee_already_synced?(trainee)
      trainee.sha == trainee.dttp_update_sha.presence
    end
  end
end
