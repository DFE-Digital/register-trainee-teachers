# frozen_string_literal: true

BURSARIES_2025_TO_2026 = [
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_undergrad],
    amount: 9_000,
    allocation_subjects: [
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 29_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 26_000,
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
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 10_000,
    allocation_subjects: [
      AllocationSubjects::ART_AND_DESIGN,
      AllocationSubjects::MUSIC,
      AllocationSubjects::RELIGIOUS_EDUCATION,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 5_000,
    allocation_subjects: [
      AllocationSubjects::ENGLISH,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
    amount: 9_000,
    allocation_subjects: [
      AllocationSubjects::ANCIENT_LANGUAGES,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::SPANISH_LANGUAGE,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 28_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
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
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 10_000,
    allocation_subjects: [
      AllocationSubjects::ART_AND_DESIGN,
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::ENGLISH,
      AllocationSubjects::MUSIC,
      AllocationSubjects::RELIGIOUS_EDUCATION,
    ],
  ),
].freeze

SCHOLARSHIPS_2025_TO_2026 = [
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 30_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 27_000,
    allocation_subjects: [
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::SPANISH_LANGUAGE,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 30_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 27_000,
    allocation_subjects: [
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::SPANISH_LANGUAGE,
    ],
  ),
].freeze

GRANTS_2025_TO_2026 = [
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
