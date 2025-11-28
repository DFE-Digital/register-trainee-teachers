# frozen_string_literal: true

BURSARIES_2025_TO_2026 = [
  OpenStruct.new(
    training_route: :provider_led_undergrad,
    amount: 9_000,
    allocation_subjects: [
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: :provider_led_postgrad,
    amount: 29_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: :provider_led_postgrad,
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
    training_route: :provider_led_postgrad,
    amount: 10_000,
    allocation_subjects: [
      AllocationSubjects::ART_AND_DESIGN,
      AllocationSubjects::MUSIC,
      AllocationSubjects::RELIGIOUS_EDUCATION,
    ],
  ),
  OpenStruct.new(
    training_route: :provider_led_postgrad,
    amount: 5_000,
    allocation_subjects: [
      AllocationSubjects::ENGLISH,
    ],
  ),
  OpenStruct.new(
    training_route: :opt_in_undergrad,
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
].freeze
