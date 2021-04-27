# frozen_string_literal: true

class RetrieveAwardJob < ApplicationJob
  queue_as :default
  retry_on Dttp::RetrieveAward::HttpError

  class TraineeAttributeError < StandardError; end

  def perform(trainee)
    awarded = Dttp::RetrieveAward.call(trainee: trainee)

    if awarded
      trainee.award!
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
    if trainee.recommended_for_award_at.nil?
      raise TraineeAttributeError, "Trainee#recommended_for_award_at is nil - it should be timestamped (id: #{trainee.id})"
    end

    trainee.recommended_for_award_at > Settings.jobs.max_poll_duration_days.days.ago
  end
end
