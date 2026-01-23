# frozen_string_literal: true

BURSARIES_2026_TO_2027 = [
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
    amount: 9_000,
    allocation_subjects: [
      AllocationSubjects::ANCIENT_LANGUAGES,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::PHYSICS,
      AllocationSubjects::SPANISH_LANGUAGE,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 5_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
      AllocationSubjects::GEOGRAPHY,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
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
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_undergrad],
    amount: 9_000,
    allocation_subjects: [
      AllocationSubjects::ENGLISH,
      AllocationSubjects::MATHEMATICS,
    ],
  ),
].freeze
