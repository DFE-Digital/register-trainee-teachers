# frozen_string_literal: true

class RetrieveTrnJob < ApplicationJob
  queue_as :default
  retry_on Dttp::RetrieveTrn::HttpError

  class TraineeAttributeError < StandardError; end

  POLL_DELAY = 6.hours
  MAX_POLL_DURATION = 2.days

  def perform(trainee_id)
    trainee = Trainee.find(trainee_id)

    trn = Dttp::RetrieveTrn.call(trainee: trainee)

    if trn
      trainee.update_and_receive_trn!(trn)
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
