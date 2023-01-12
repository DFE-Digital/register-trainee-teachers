# frozen_string_literal: true

module Trainees
  class MapStateFromHesa
    include ServicePattern

    def initialize(hesa_trainee:, trainee:)
      @hesa_trainee = hesa_trainee
      @trainee = trainee
      @trn = trainee.trn || hesa_trainee[:trn]
    end

    def call
      return :awarded if trainee.awarded?
      return :deferred if trainee_dormant? && !withdrawn?
      # If the trainee has completed the course, but the result is unknown we
      # do not know enough to transition their state. If it's the first time
      # we're seeing this trainee, they are created as trn_received (line 41)
      return nil if trainee.persisted? && completed_with_unknown_result?
      return :submitted_for_trn if submitted_for_trn?
      return :trn_received if trn_received?

      :withdrawn if withdrawn?
    end

  private

    attr_reader :hesa_trainee, :trn, :trainee

    def trainee_dormant?
      [
        Hesa::CodeSets::Modes::DORMANT_FULL_TIME,
        Hesa::CodeSets::Modes::DORMANT_PART_TIME,
      ].include?(mode)
    end

    def submitted_for_trn?
      (reason_for_leaving.blank? || completed_with_unknown_result?) && trn.blank?
    end

    def trn_received?
      (reason_for_leaving.blank? || completed_with_unknown_result?) && trn.present?
    end

    def withdrawn?
      [
        WithdrawalReasons::TRANSFERRED_TO_ANOTHER_PROVIDER,
        WithdrawalReasons::DEATH,
        WithdrawalReasons::FOR_ANOTHER_REASON,
      ].include?(reason_for_leaving) && hesa_trainee[:end_date].present?
    end

    def completed_with_unknown_result?
      [
        completed_with_credit_or_award?,
        completed_with_credit_or_award_unknown?,
      ].any?
    end

    def completed_with_credit_or_award?
      reason_for_leaving == Hesa::CodeSets::ReasonsForLeavingCourse::COMPLETED_WITH_CREDIT_OR_AWARD
    end

    def completed_with_credit_or_award_unknown?
      reason_for_leaving == Hesa::CodeSets::ReasonsForLeavingCourse::COMPLETED_WITH_CREDIT_OR_AWARD_UNKNOWN
    end

    def reason_for_leaving
      Hesa::CodeSets::ReasonsForLeavingCourse::MAPPING[hesa_trainee[:reason_for_leaving]]
    end

    def mode
      Hesa::CodeSets::Modes::MAPPING[hesa_trainee[:mode]]
    end
  end
end
