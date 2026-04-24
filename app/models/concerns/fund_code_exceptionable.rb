# frozen_string_literal: true

module FundCodeExceptionable
  extend ActiveSupport::Concern

  FUND_CODE_EXCEPTION_ALLOCATION_SUBJECTS = [
    AllocationSubjects::ANCIENT_LANGUAGES,
    AllocationSubjects::MODERN_LANGUAGES,
    AllocationSubjects::FRENCH_LANGUAGE,
    AllocationSubjects::GERMAN_LANGUAGE,
    AllocationSubjects::SPANISH_LANGUAGE,
    AllocationSubjects::PHYSICS,
  ].freeze

  FUND_CODE_EXCEPTIONS_START_YEARS = [2025, 2026].freeze

private

  def fund_code_exception?
    return false unless academic_cycle

    academic_cycle.start_year.in?(FUND_CODE_EXCEPTIONS_START_YEARS) &&
      AllocationSubject.exists?(name: FUND_CODE_EXCEPTION_ALLOCATION_SUBJECTS,
                                id: course_allocation_subject_id)
  end
end
