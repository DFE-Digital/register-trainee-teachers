# frozen_string_literal: true

module Trainees
  class Withdraw
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
      @trs_enabled = FeatureService.enabled?(:integrate_with_trs)
    end

    def call
      # Check whether the integration is enabled and enqueue the appropriate job
      if trs_enabled
        Trs::UpdateProfessionalStatusJob.perform_later(trainee)
      end

      Survey::SendJob.set(wait: Settings.qualtrics.days_delayed.days).perform_later(trainee: trainee, event_type: :withdraw) if trainee_withdrawal_valid_for_survey?
    end

  private

    attr_reader :trainee, :trs_enabled

    def trainee_withdrawal_valid_for_survey?
      reason_names = trainee&.current_withdrawal&.withdrawal_reasons&.pluck(:name)
      return false if reason_names.blank?

      # Only prevent survey if RECORD_ADDED_IN_ERROR is the sole reason
      reason_names != [WithdrawalReasons::RECORD_ADDED_IN_ERROR]
    end
  end
end
