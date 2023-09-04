# frozen_string_literal: true

module Dqt
  class WithdrawTraineeJob < Dqt::BaseJob
    include NotifyOnTimeout

    sidekiq_options retry: 0
    queue_as :dqt

    class TraineeAttributeError < StandardError; end

    def perform(trainee, timeout_after = nil)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      @trainee = trainee
      @timeout_after = timeout_after

      if timeout_after.nil?
        @timeout_after = Settings.jobs.max_poll_duration_days.days.from_now
        requeue
        return
      end

      if trainee.trn.present?
        WithdrawTrainee.call(trainee:)
      elsif continue_waiting_for_trn?
        requeue
      else
        send_message_to_slack(trainee, self.class.name)
      end
    end

  private

    attr_reader :trainee, :timeout_after

    def continue_waiting_for_trn?
      Time.zone.now.utc < timeout_after
    end

    def requeue
      self.class.set(wait: Settings.jobs.poll_delay_hours.hours).perform_later(trainee, timeout_after)
    end
  end
end
