# frozen_string_literal: true

class QueueTraineeUpdatesJob < ApplicationJob
  queue_as :dttp

  INVALID_STATES = %w[
    draft
    recommended_for_qts
    withdrawn
    deferred
    qts_awarded
  ].freeze

  def perform
    trainees = fetch_trainees

    return if trainees.blank?

    trainees.each do |trainee|
      UpdateTraineeToDttpJob.perform_later(trainee)
    end
  end

private

  def fetch_trainees
    Trainee.where.not(state: INVALID_STATES)
  end
end
