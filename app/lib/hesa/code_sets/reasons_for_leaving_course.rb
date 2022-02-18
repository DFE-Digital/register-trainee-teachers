# frozen_string_literal: true

module Hesa
  module CodeSets
    module ReasonsForLeavingCourse
      SUCCESSFUL_COMPLETION = "Successful completion of course"
      UNKNOWN_COMPLETION = "Completion of course - result unknown"

      MAPPING = {
        "01" => SUCCESSFUL_COMPLETION,
        "02" => WithdrawalReasons::DID_NOT_PASS_EXAMS,
        "03" => WithdrawalReasons::TRANSFERRED_TO_ANOTHER_PROVIDER,
        "04" => WithdrawalReasons::HEALTH_REASONS,
        "05" => WithdrawalReasons::DEATH,
        "06" => WithdrawalReasons::FINANCIAL_REASONS,
        "07" => WithdrawalReasons::PERSONAL_REASONS,
        "08" => WithdrawalReasons::WRITTEN_OFF_AFTER_LAPSE_OF_TIME,
        "09" => WithdrawalReasons::EXCLUSION,
        "10" => WithdrawalReasons::GONE_INTO_EMPLOYMENT,
        "11" => WithdrawalReasons::FOR_ANOTHER_REASON,
        "98" => UNKNOWN_COMPLETION,
        "99" => WithdrawalReasons::UNKNOWN,
      }.freeze
    end
  end
end
