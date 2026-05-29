# frozen_string_literal: true

class FundCodeException
  ALLOCATION_SUBJECTS = [
    AllocationSubjects::ANCIENT_LANGUAGES,
    AllocationSubjects::MODERN_LANGUAGES,
    AllocationSubjects::FRENCH_LANGUAGE,
    AllocationSubjects::GERMAN_LANGUAGE,
    AllocationSubjects::SPANISH_LANGUAGE,
    AllocationSubjects::PHYSICS,
  ].freeze

  START_YEARS = [2025, 2026].freeze

  def self.applies_to?(allocation_subject:, academic_cycle:)
    return false unless allocation_subject && academic_cycle

    academic_cycle.start_year.in?(START_YEARS) &&
      allocation_subject.name.in?(ALLOCATION_SUBJECTS)
  end
end
