# frozen_string_literal: true

module Trainees
  class MapStateFromHesa
    include ServicePattern

    def initialize(hesa_trainee:)
      @hesa_trainee = hesa_trainee
      @trn = hesa_trainee[:trn]
    end

    def call
      return :submitted_for_trn if submitted_for_trn?
      return :trn_received if trn_received?
      return :withdrawn if withdrawn?
      return :deferred if trainee_dormant?

      :awarded if successful_completion_of_course?
    end

  private

    attr_reader :hesa_trainee, :trn

    def submitted_for_trn?
      reason_for_leaving.blank? && trn.blank? && !trainee_dormant?
    end

    def trn_received?
      reason_for_leaving.blank? && trn.present? && !trainee_dormant?
    end

    def withdrawn?
      reason_for_leaving.present? && course_not_completed? && hesa_trainee[:end_date].present?
    end

    def course_not_completed?
      [
        successful_completion_of_course?,
        completion_of_course_result_unknown?,
      ].none?
    end

    def successful_completion_of_course?
      reason_for_leaving == Hesa::CodeSets::ReasonsForLeavingCourse::SUCCESSFUL_COMPLETION
    end

    def completion_of_course_result_unknown?
      reason_for_leaving == Hesa::CodeSets::ReasonsForLeavingCourse::UNKNOWN_COMPLETION
    end

    def reason_for_leaving
      Hesa::CodeSets::ReasonsForLeavingCourse::MAPPING[hesa_trainee[:reason_for_leaving]]
    end

    def trainee_dormant?
      [
        Hesa::CodeSets::Modes::DORMANT_FULL_TIME,
        Hesa::CodeSets::Modes::DORMANT_PART_TIME,
      ].include?(mode)
    end

    def mode
      Hesa::CodeSets::Modes::MAPPING[hesa_trainee[:mode]]
    end
  end
end
