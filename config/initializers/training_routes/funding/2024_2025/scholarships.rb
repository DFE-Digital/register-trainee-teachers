# frozen_string_literal: true

SCHOLARSHIPS_2024_TO_2025 = [
  OpenStruct.new(
    training_route: :provider_led_postgrad,
    amount: 30_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: :provider_led_postgrad,
    amount: 27_000,
    allocation_subjects: [
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::SPANISH_LANGUAGE,
    ],
  ),
  OpenStruct.new(
    training_route: :school_direct_tuition_fee,
    amount: 30_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: :school_direct_tuition_fee,
    amount: 27_000,
    allocation_subjects: [
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::SPANISH_LANGUAGE,
    ],
  ),
].freeze
