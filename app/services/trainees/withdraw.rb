# frozen_string_literal: true

module Trainees
  class Withdraw
    include ServicePattern
    include HandlesIntegrationConflicts

    def initialize(trainee:)
      @trainee = trainee
      @dqt_enabled = FeatureService.enabled?(:integrate_with_dqt)
      @trs_enabled = FeatureService.enabled?(:integrate_with_trs)
    end

    def call
      check_for_conflicting_integrations

      # Check which integration is enabled and enqueue the appropriate job
      # Don't call TRS if the trainee's TRN has not been received yet
      if trs_enabled && trainee.trn.present?
        Trs::UpdateProfessionalStatusJob.perform_later(trainee)
      elsif dqt_enabled
        Dqt::WithdrawTraineeJob.perform_later(trainee)
      end

      Survey::SendJob.set(wait: Settings.qualtrics.days_delayed.days).perform_later(trainee: trainee, event_type: :withdraw) if trainee_withdrawal_valid_for_survey?
    end

  private

    attr_reader :trainee, :dqt_enabled, :trs_enabled

    def trainee_withdrawal_valid_for_survey?
      reason_names = trainee&.current_withdrawal&.withdrawal_reasons&.pluck(:name)
      return false if reason_names.blank?

      # Only prevent survey if RECORD_ADDED_IN_ERROR is the sole reason
      reason_names != [WithdrawalReasons::RECORD_ADDED_IN_ERROR]
    end
  end
end
