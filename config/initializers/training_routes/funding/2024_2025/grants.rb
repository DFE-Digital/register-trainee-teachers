# frozen_string_literal: true

GRANTS_2024_TO_2025 = [
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:early_years_postgrad],
    amount: 7_000,
    allocation_subjects: [
      AllocationSubjects::EARLY_YEARS_ITT,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:early_years_salaried],
    amount: 14_000,
    allocation_subjects: [
      AllocationSubjects::EARLY_YEARS_ITT,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 28_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 25_000,
    allocation_subjects: [
      AllocationSubjects::ANCIENT_LANGUAGES,
      AllocationSubjects::BIOLOGY,
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::SPANISH_LANGUAGE,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 10_000,
    allocation_subjects: [
      AllocationSubjects::ART_AND_DESIGN,
      AllocationSubjects::ENGLISH,
      AllocationSubjects::MUSIC,
      AllocationSubjects::RELIGIOUS_EDUCATION,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 28_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 25_000,
    allocation_subjects: [
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::SPANISH_LANGUAGE,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 16_000,
    allocation_subjects: [
      AllocationSubjects::ANCIENT_LANGUAGES,
      AllocationSubjects::BIOLOGY,
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 1_000,
    allocation_subjects: [
      AllocationSubjects::ART_AND_DESIGN,
      AllocationSubjects::ENGLISH,
      AllocationSubjects::MUSIC,
      AllocationSubjects::RELIGIOUS_EDUCATION,
    ],
  ),
].freeze
