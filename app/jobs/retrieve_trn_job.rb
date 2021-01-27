# frozen_string_literal: true

class RetrieveTrnJob < ApplicationJob
  queue_as :default
  retry_on Dttp::RetrieveTrn::HttpError

  class TraineeAttributeError < StandardError; end

  POLL_DELAY = Settings.jobs.poll_delay_hours.hours
  MAX_POLL_DURATION = Settings.jobs.max_poll_duration_days.days

  def perform(trainee_id)
    trainee = Trainee.find(trainee_id)

    trn = Dttp::RetrieveTrn.call(trainee: trainee)

    if trn
      trainee.trn_received!(trn)
    elsif continue_polling?(trainee)
      RetrieveTrnJob.set(wait: POLL_DELAY).perform_later(trainee.id)
    end
  end

private

  def continue_polling?(trainee)
    if trainee.submitted_for_trn_at.nil?
      raise TraineeAttributeError, "Trainee#submitted_for_trn_at is nil - it should be timestamped (id: #{trainee.id})"
    end

    trainee.submitted_for_trn_at > MAX_POLL_DURATION.ago
  end
end
