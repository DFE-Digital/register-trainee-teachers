# frozen_string_literal: true

module WithdrawalReasons
  DEATH = "death"
  DID_NOT_PASS_ASSESSMENT = "did_not_pass_assessment"
  DID_NOT_PASS_EXAMS = "did_not_pass_exams"
  EXCLUSION = "exclusion"
  FINANCIAL_REASONS = "financial_reasons"
  FOR_ANOTHER_REASON = "for_another_reason"
  GONE_INTO_EMPLOYMENT = "gone_into_employment"
  HEALTH_REASONS = "health_reasons"
  PERSONAL_REASONS = "personal_reasons"
  TRANSFERRED_TO_ANOTHER_PROVIDER = "transferred_to_another_provider"
  UNKNOWN = "unknown"
  WRITTEN_OFF_AFTER_LAPSE_OF_TIME = "written_off_after_lapse_of_time"

  SPECIFIC = [
    DEATH,
    DID_NOT_PASS_ASSESSMENT,
    DID_NOT_PASS_EXAMS,
    EXCLUSION,
    FINANCIAL_REASONS,
    GONE_INTO_EMPLOYMENT,
    HEALTH_REASONS,
    PERSONAL_REASONS,
    TRANSFERRED_TO_ANOTHER_PROVIDER,
    WRITTEN_OFF_AFTER_LAPSE_OF_TIME,
  ].freeze
end
