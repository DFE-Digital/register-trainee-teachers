# frozen_string_literal: true

class RetrieveQtsJob < ApplicationJob
  queue_as :default
  retry_on Dttp::RetrieveQts::HttpError

  class TraineeAttributeError < StandardError; end

  POLL_DELAY = Settings.jobs.poll_delay_hours.hours
  MAX_POLL_DURATION = Settings.jobs.max_poll_duration_days.days

  def perform(trainee_id)
    trainee = Trainee.find(trainee_id)

    qts_awarded = Dttp::RetrieveQts.call(trainee: trainee)

    if qts_awarded
      trainee.award_qts!
    elsif continue_polling?(trainee)
      RetrieveQtsJob.set(wait: POLL_DELAY).perform_later(trainee.id)
    end
  end

private

  def continue_polling?(trainee)
    if trainee.recommended_for_qts_at.nil?
      raise TraineeAttributeError, "Trainee#recommended_for_qts_at is nil - it should be timestamped (id: #{trainee.id})"
    end

    trainee.recommended_for_qts_at > MAX_POLL_DURATION.ago
  end
end
