# frozen_string_literal: true

module Dqt
  class RetrieveTrnJob < ApplicationJob
    queue_as :dqt
    retry_on Client::HttpError
    include NotifyOnTimeout

    class TraineeAttributeError < StandardError; end

    def perform(trn_request, timeout_after = nil)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      @trn_request = trn_request
      @timeout_after = timeout_after
      @trainee = trn_request.trainee

      if @timeout_after.nil?
        self.class.perform_later(trn_request, trainee.submitted_for_trn_at + Settings.jobs.max_poll_duration_days.days)
        return
      end

      trn = Dqt::RetrieveTrn.call(trn_request:)

      if trn
        trainee.trn_received!(trn)
        trn_request.received!
      elsif continue_polling?
        requeue
      else
        send_message_to_slack(trainee, self.class.name)
      end
    end

  private

    attr_reader :trn_request, :trainee, :timeout_after

    def continue_polling?
      if trainee.submitted_for_trn_at.nil?
        raise(TraineeAttributeError, "Trainee#submitted_for_trn_at is nil - it should be timestamped (id: #{trainee.id})")
      end

      Time.zone.now.utc < timeout_after
    end

    def requeue
      self.class.set(wait: Settings.jobs.poll_delay_hours.hours).perform_later(trn_request, timeout_after)
    end
  end
end
