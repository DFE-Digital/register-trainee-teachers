# frozen_string_literal: true

GRANTS_2026_TO_2027 = [
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:early_years_salaried],
    amount: 16_535,
    allocation_subjects: [
      AllocationSubjects::EARLY_YEARS_ITT,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 5_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
      AllocationSubjects::GEOGRAPHY,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 20_000,
    allocation_subjects: [
      AllocationSubjects::ANCIENT_LANGUAGES,
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::SPANISH_LANGUAGE,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 29_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 5_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
      AllocationSubjects::GEOGRAPHY,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 20_000,
    allocation_subjects: [
      AllocationSubjects::ANCIENT_LANGUAGES,
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::SPANISH_LANGUAGE,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 29_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
].freeze
