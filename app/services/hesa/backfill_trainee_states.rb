# frozen_string_literal: true

module Hesa
  class BackfillTraineeStates
    include ServicePattern

    def initialize(trainee:)
      @collection_reference = Settings.hesa.current_collection_reference
      @trainee = trainee
      @hesa_student = trainee.hesa_student_for_collection(collection_reference)
    end

    def call
      if hesa_student && withdrawn?
        trainee.update_columns(state: "withdrawn", withdraw_reason: reason_for_leaving, withdraw_date: hesa_student.end_date)
      end
    end

  private

    attr_reader :hesa_student, :trainee, :collection_reference

    def withdrawn?
      [
        WithdrawalReasons::TRANSFERRED_TO_ANOTHER_PROVIDER,
        WithdrawalReasons::DEATH,
        WithdrawalReasons::FOR_ANOTHER_REASON,
      ].include?(reason_for_leaving) && hesa_student.end_date.present?
    end

    def reason_for_leaving
      Hesa::CodeSets::ReasonsForLeavingCourse::MAPPING[hesa_student.reason_for_leaving]
    end
  end
end
