# frozen_string_literal: true

class RetrieveQtsJob < ApplicationJob
  queue_as :default
  retry_on Dttp::RetrieveQts::HttpError

  class TraineeAttributeError < StandardError; end

  def perform(trainee)
    qts_awarded = Dttp::RetrieveQts.call(trainee: trainee)

    if qts_awarded
      trainee.award_qts!
    elsif continue_polling?(trainee)
      self.class.set(wait: Settings.jobs.poll_delay_hours.hours).perform_later(trainee)
    end
  end

  class << self
    def perform_with_default_delay(trainee)
      set(wait: Settings.jobs.poll_delay_hours.hours).perform_later(trainee)
    end
  end

private

  def continue_polling?(trainee)
    if trainee.recommended_for_qts_at.nil?
      raise TraineeAttributeError, "Trainee#recommended_for_qts_at is nil - it should be timestamped (id: #{trainee.id})"
    end

    trainee.recommended_for_qts_at > Settings.jobs.max_poll_duration_days.days.ago
  end
end
