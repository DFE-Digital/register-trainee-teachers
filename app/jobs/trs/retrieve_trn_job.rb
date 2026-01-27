# frozen_string_literal: true

module Trs
  class RetrieveTrnJob < Trs::BaseJob
    queue_as :trs
    retry_on Client::HttpError
    include NotifyOnTimeout

    class TraineeAttributeError < StandardError; end

    def perform(trn_request, timeout_after = nil)
      return unless FeatureService.enabled?(:integrate_with_trs)

      @trn_request = trn_request
      @timeout_after = timeout_after
      @trainee = trn_request.trainee

      if trainee.discarded?
        trn_request.destroy
        return
      end

      # Return early if the trainee already has a TRN
      if trainee.trn.present?
        trn_request.received! unless trn_request.received?
        return
      end

      if @timeout_after.nil?
        schedule_next_attempt
        return
      end

      process_trn_request
    end

  private

    attr_reader :trn_request, :trainee, :timeout_after

    def schedule_next_attempt
      next_attempt_time = trainee.submitted_for_trn_at + timeout_duration
      self.class.perform_later(trn_request, next_attempt_time)
    end

    def process_trn_request
      trn = RetrieveTrn.call(trn_request:)

      if trn
        trainee.trn_received!(trn)
        trn_request.received!
        UpdateProfessionalStatusJob.set(wait: 1.minute).perform_later(trainee)
      elsif continue_polling?
        requeue
      else
        notify_failure
      end
    end

    def continue_polling?
      validate_trainee_attributes
      Time.zone.now.utc < timeout_after
    end

    def validate_trainee_attributes
      if trainee.submitted_for_trn_at.nil?
        raise(TraineeAttributeError, "Trainee#submitted_for_trn_at is nil - it should be timestamped (id: #{trainee.id})")
      end
    end

    def requeue
      self.class.set(wait: Settings.jobs.poll_delay_hours.hours).perform_later(trn_request, timeout_after)
    end

    def notify_failure
      send_message_to_slack(trainee, self.class.name)
    end

    def timeout_duration
      return (Settings.jobs.max_poll_duration_days + 6).days if Time.zone.now.month == 10 # Increase timeout for jobs during October to deal with increased registrations

      Settings.jobs.max_poll_duration_days.days
    end
  end
end
