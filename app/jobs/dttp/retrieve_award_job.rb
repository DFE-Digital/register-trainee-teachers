# frozen_string_literal: true

module Dttp
  class RetrieveAwardJob < ApplicationJob
    queue_as :default
    retry_on Client::HttpError
    include NotifyOnTimeout

    class TraineeAttributeError < StandardError; end

    def perform(trainee, timeout_after = nil)
      return unless FeatureService.enabled?(:persist_to_dttp)

      @timeout_after = timeout_after
      @trainee = trainee

      if @timeout_after.nil?
        self.class.perform_later(trainee, trainee.recommended_for_award_at + Settings.jobs.max_poll_duration_days.days)
        return
      end

      if awarded?
        trainee.awarded_at = award_status["dfe_qtseytsawarddate"]
        trainee.award!
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

    attr_reader :timeout_after, :trainee

    def award_status
      @award_status ||= RetrieveAward.call(trainee: trainee)
    end

    def awarded?
      award_status&.dig("dfe_qtsawardflag")
    end

    def continue_polling?
      if trainee.recommended_for_award_at.nil?
        raise TraineeAttributeError, "Trainee#recommended_for_award_at is nil - it should be timestamped (id: #{trainee.id})"
      end

      Time.zone.now.utc < timeout_after
    end

    def requeue
      self.class.set(wait: Settings.jobs.poll_delay_hours.hours).perform_later(trainee, timeout_after)
    end
  end
end
