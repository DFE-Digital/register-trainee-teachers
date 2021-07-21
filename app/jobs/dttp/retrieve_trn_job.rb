# frozen_string_literal: true

module Dttp
  class RetrieveTrnJob < ApplicationJob
    queue_as :default
    retry_on Client::HttpError
    include NotifyOnTimeout
    include ClockoverDependent

    class TraineeAttributeError < StandardError; end

    def perform(trainee, timeout_after = nil)
      @timeout_after = timeout_after
      @trainee = trainee

      if before_clockover? && trainee_is_not_assessment_only?
        requeue_after_clockover
        return
      end

      if @timeout_after.nil?
        self.class.perform_later(trainee, trainee.submitted_for_trn_at + Settings.jobs.max_poll_duration_days.days)
        return
      end

      trn = Dttp::RetrieveTrn.call(trainee: trainee)

      if trn
        trainee.trn_received!(trn)
      elsif continue_polling?
        requeue
      else
        send_message_to_slack(trainee, self.class.name)
      end
    end

    class << self
      def perform_with_default_delay(trainee)
        set(wait: Settings.jobs.poll_delay_hours.hours)
          .perform_later(trainee, Settings.jobs.max_poll_duration_days.days.from_now)
      end
    end

  private

    attr_reader :trainee, :timeout_after

    def continue_polling?
      if trainee.submitted_for_trn_at.nil?
        raise TraineeAttributeError, "Trainee#submitted_for_trn_at is nil - it should be timestamped (id: #{trainee.id})"
      end

      Time.zone.now.utc < timeout_after
    end

    def requeue
      self.class.set(wait: Settings.jobs.poll_delay_hours.hours).perform_later(trainee, timeout_after)
    end

    def requeue_after_clockover
      self.class.set(wait_until: clockover_date).perform_later(trainee, clockover_date + Settings.jobs.max_poll_duration_days.days)
    end

    def trainee_is_not_assessment_only?
      !(trainee.assessment_only? || trainee.early_years_assessment_only?)
    end
  end
end
