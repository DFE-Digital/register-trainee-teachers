# frozen_string_literal: true

module WithdrawalReasons
  # legacy ENUM values
  # TODO: remove once migrated
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
  LEGACY_UNKNOWN = "unknown"
  WRITTEN_OFF_AFTER_LAPSE_OF_TIME = "written_off_after_lapse_of_time"

  # Reason names
  TIME = "Time"
  UNSUITABLE = "Unsuitable"
  PROGRESS = "Progress"
  ENTRY_REQUIREMENTS = "Entry requirements"
  UNWANTED = "Unwanted"
  FAMILY_PROBLEMS = "Family problems"
  FINANCIAL_PROBLEMS = "Financial problems"
  JOB = "Job"
  HEALTH_PROBLEMS = "Health problems"
  STOPPED_RESPONDING = "Stopped responding"
  PLACEMENT_PROBLEMS = "Placement problems"
  BEHAVIOUR = "Behaviour"
  UNHAPPY = "Unhappy"
  ANOTHER_REASON = "Another reason"
  UNKNOWN = "Unknown"

  # Legacy reason names
  LEGACY_DEATH = "Death"
  LEGACY_EXCLUSION = "Exclusion"
  LEGACY_PERSONAL_REASONS = "Personal reasons"
  LEGACY_TRANSFERRED = "Transferred"
  LEGACY_WRITTEN_OFF = "Written off"
  LEGACY_FAILED_ASSESSMENT = "Failed assessment"
  LEGACY_FAILED_EXAM = "Failed exam"

  SPECIFIC = [
    TIME,
    UNSUITABLE,
    PROGRESS,
    ENTRY_REQUIREMENTS,
    UNWANTED,
    FAMILY_PROBLEMS,
    FINANCIAL_PROBLEMS,
    JOB,
    HEALTH_PROBLEMS,
    STOPPED_RESPONDING,
    PLACEMENT_PROBLEMS,
    BEHAVIOUR,
    UNHAPPY,
    ANOTHER_REASON,
    UNKNOWN,
  ].freeze

  LEGACY_MAPPINGS = {
    LEGACY_DEATH => DEATH,
    DID_NOT_PASS_ASSESSMENT => LEGACY_FAILED_ASSESSMENT,
    DID_NOT_PASS_EXAMS => LEGACY_FAILED_EXAM,
    EXCLUSION => LEGACY_EXCLUSION,
    FINANCIAL_REASONS => FINANCIAL_PROBLEMS,
    FOR_ANOTHER_REASON => ANOTHER_REASON,
    GONE_INTO_EMPLOYMENT => JOB,
    HEALTH_REASONS => HEALTH_PROBLEMS,
    PERSONAL_REASONS => LEGACY_PERSONAL_REASONS,
    TRANSFERRED_TO_ANOTHER_PROVIDER => LEGACY_TRANSFERRED,
    LEGACY_UNKNOWN => UNKNOWN,
    WRITTEN_OFF_AFTER_LAPSE_OF_TIME => LEGACY_WRITTEN_OFF,
  }.freeze

  REASONS = [
    { name: TIME, description: "Could not give enough time to course" },
    { name: UNSUITABLE, description: "Course was not suitable for them" },
    { name: PROGRESS, description: "Did not make progress in course" },
    { name: ENTRY_REQUIREMENTS, description: "Did not meet course entry requirements" },
    { name: UNWANTED, description: "Does not want to become a teacher" },
    { name: FAMILY_PROBLEMS, description: "Family problems" },
    { name: FINANCIAL_PROBLEMS, description: "Financial problems" },
    { name: JOB, description: "Got a job" },
    { name: HEALTH_PROBLEMS, description: "Problems with their health" },
    { name: STOPPED_RESPONDING, description: "Stopped responding to messages" },
    { name: PLACEMENT_PROBLEMS, description: "Teaching placement problems" },
    { name: BEHAVIOUR, description: "Unacceptable behaviour" },
    { name: UNHAPPY, description: "Unhappy with course, provider or employing school" },
    { name: ANOTHER_REASON, description: "Another reason" },
    { name: UNKNOWN, description: "Unknown" },
  ].freeze

  # these have no direct mapping to the new reasons
  LEGACY_REASONS = [
    { name: LEGACY_DEATH, description: "Death" },
    { name: LEGACY_EXCLUSION, description: "Exclusion" },
    { name: LEGACY_PERSONAL_REASONS, description: "Personal reasons" },
    { name: LEGACY_TRANSFERRED, description: "Transferred to another provider" },
    { name: LEGACY_WRITTEN_OFF, description: "Written off after lapse of time" },
    { name: LEGACY_FAILED_ASSESSMENT, description: "Did no pass assessment" },
    { name: LEGACY_FAILED_EXAM, description: "Did no pass the exams" },
  ].freeze

  SEEDS = [*REASONS, *LEGACY_REASONS].freeze
end
