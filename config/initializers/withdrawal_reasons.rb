# frozen_string_literal: true

module WithdrawalReasons
  # Legacy reasons
  DEATH = "death"
  DID_NOT_PASS_ASSESSMENT = "did_not_pass_assessment"
  DID_NOT_PASS_EXAMS = "did_not_pass_exams"
  EXCLUSION = "exclusion"
  PERSONAL_REASONS = "personal_reasons"
  TRANSFERRED_TO_ANOTHER_PROVIDER = "transferred_to_another_provider"
  WRITTEN_OFF_AFTER_LAPSE_OF_TIME = "written_off_after_lapse_of_time"
  FINANCIAL_REASONS = "financial_reasons"
  GONE_INTO_EMPLOYMENT = "gone_into_employment"
  HEALTH_REASONS = "health_reasons"
  FOR_ANOTHER_REASON = "for_another_reason"

  # New reasons June 2023 https://trello.com/c/HPlzoKk1/5423
  FINANCIAL_PROBLEMS = "financial_problems"
  ANOTHER_REASON = "another_reason"
  GOT_A_JOB = "got_a_job"
  PROBLEMS_WITH_THEIR_HEALTH = "problems_with_their_health"
  UNKNOWN = "unknown"
  COULD_NOT_GIVE_ENOUGH_TIME = "could_not_give_enough_time"
  COURSE_WAS_NOT_SUITABLE = "course_was_not_suitable"
  DID_NOT_MAKE_PROGRESS = "did_not_make_progress"
  DID_NOT_MEET_ENTRY_REQUIREMENTS = "did_not_meet_entry_requirements"
  DOES_NOT_WANT_TO_BECOME_A_TEACHER = "does_not_want_to_become_a_teacher"
  FAMILY_PROBLEMS = "family_problems"
  STOPPED_RESPONDING_TO_MESSAGES = "stopped_responding_to_messages"
  TEACHING_PLACEMENT_PROBLEMS = "teaching_placement_problems"
  UNACCEPTABLE_BEHAVIOUR = "unacceptable_behaviour"
  UNHAPPY_WITH_COURSE_PROVIDER_OR_EMPLOYING_SCHOOL = "unhappy_with_course_provider_or_employing_school"

  # New reasons November 2024
  RECORD_ADDED_IN_ERROR = "record_added_in_error"
  MANDATORY_REASONS = "mandatory_reasons"
  LACK_OF_PROGRESS_DURING_PLACEMENTS = "lack_of_progress_during_placements"
  NOT_MEETING_QTS_STANDARDS = "not_meeting_qts_standards"
  TRAINEE_WORKLOAD_ISSUES = "trainee_workload_issues"
  CHANGE_IN_PERSONAL_OR_HEALTH_CIRCUMSTANCES = "change_in_personal_or_health_circumstances"
  NEVER_INTENDED_TO_OBTAIN_QTS = "never_intended_to_obtain_qts"
  MOVED_TO_DIFFERENT_ITT_COURSE = "moved_to_different_itt_course"

  LEGACY_REASONS = [
    DEATH,
    DID_NOT_PASS_ASSESSMENT,
    DID_NOT_PASS_EXAMS,
    EXCLUSION,
    PERSONAL_REASONS,
    TRANSFERRED_TO_ANOTHER_PROVIDER,
    WRITTEN_OFF_AFTER_LAPSE_OF_TIME,
  ].freeze

  LEGACY_2023_REASONS = [
    COULD_NOT_GIVE_ENOUGH_TIME,
    COURSE_WAS_NOT_SUITABLE,
    DID_NOT_MEET_ENTRY_REQUIREMENTS,
    FAMILY_PROBLEMS,
    FINANCIAL_PROBLEMS,
    GOT_A_JOB,
    PROBLEMS_WITH_THEIR_HEALTH,
    TEACHING_PLACEMENT_PROBLEMS,
    UNHAPPY_WITH_COURSE_PROVIDER_OR_EMPLOYING_SCHOOL,
  ].freeze

  REASONS = [
    UNACCEPTABLE_BEHAVIOUR,
    DID_NOT_MAKE_PROGRESS,
    DOES_NOT_WANT_TO_BECOME_A_TEACHER,
    STOPPED_RESPONDING_TO_MESSAGES,
    ANOTHER_REASON,
    UNKNOWN,
    RECORD_ADDED_IN_ERROR,
    MANDATORY_REASONS,
    LACK_OF_PROGRESS_DURING_PLACEMENTS,
    NOT_MEETING_QTS_STANDARDS,
    TRAINEE_WORKLOAD_ISSUES,
    CHANGE_IN_PERSONAL_OR_HEALTH_CIRCUMSTANCES,
    NEVER_INTENDED_TO_OBTAIN_QTS,
    MOVED_TO_DIFFERENT_ITT_COURSE,
  ].freeze

  LEGACY_MAPPING = {
    FINANCIAL_REASONS => FINANCIAL_PROBLEMS,
    GONE_INTO_EMPLOYMENT => GOT_A_JOB,
    HEALTH_REASONS => PROBLEMS_WITH_THEIR_HEALTH,
    FOR_ANOTHER_REASON => ANOTHER_REASON,
  }.freeze

  SEED = (LEGACY_REASONS + LEGACY_2023_REASONS + REASONS).map { |name| { name: } }.freeze
end
