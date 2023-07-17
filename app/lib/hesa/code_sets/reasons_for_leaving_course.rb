# frozen_string_literal: true

module Hesa
  module CodeSets
    module ReasonsForLeavingCourse
      COMPLETED_WITH_CREDIT_OR_AWARD = "Left and awarded credit or a qualification"
      COMPLETED_WITH_CREDIT_OR_AWARD_UNKNOWN = "Left but award of credit or a qualification not yet known"

      MAPPING = {
        "01" =>	COMPLETED_WITH_CREDIT_OR_AWARD,
        "03" =>	WithdrawalReasons::TRANSFERRED_TO_ANOTHER_PROVIDER,
        "05" =>	WithdrawalReasons::DEATH,
        "11" =>	WithdrawalReasons::ANOTHER_REASON,
        "98" =>	COMPLETED_WITH_CREDIT_OR_AWARD_UNKNOWN,
      }.freeze
    end
  end
end
