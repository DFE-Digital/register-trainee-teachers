# frozen_string_literal: true

SCHOLARSHIPS_2026_TO_2027 = [
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 22_000,
    allocation_subjects: [
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::SPANISH_LANGUAGE,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 31_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::PHYSICS,
    ],
  ),
].freeze
