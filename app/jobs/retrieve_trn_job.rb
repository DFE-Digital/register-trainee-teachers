# frozen_string_literal: true

class RetrieveTrnJob < ApplicationJob
  queue_as :default
  retry_on Dttp::RetrieveTrn::HttpError

  class TraineeAttributeError < StandardError; end

  def perform(trainee)
    trn = Dttp::RetrieveTrn.call(trainee: trainee)

    if trn
      trainee.trn_received!(trn)
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
    if trainee.submitted_for_trn_at.nil?
      raise TraineeAttributeError, "Trainee#submitted_for_trn_at is nil - it should be timestamped (id: #{trainee.id})"
    end

    trainee.submitted_for_trn_at > Settings.jobs.max_poll_duration_days.days.ago
  end
end
