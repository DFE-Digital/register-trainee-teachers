# frozen_string_literal: true

BURSARIES_2023_TO_2024 = [
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
    amount: 27_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: :provider_led_postgrad,
    amount: 25_000,
    allocation_subjects: [
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: :provider_led_postgrad,
    amount: 20_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
    ],
  ),
  OpenStruct.new(
    training_route: :provider_led_postgrad,
    amount: 15_000,
    allocation_subjects: [
      AllocationSubjects::ENGLISH,
    ],
  ),
  OpenStruct.new(
    training_route: :opt_in_undergrad,
    amount: 9_000,
    allocation_subjects: [
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: :school_direct_tuition_fee,
    amount: 27_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: :school_direct_tuition_fee,
    amount: 25_000,
    allocation_subjects: [
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: :school_direct_tuition_fee,
    amount: 20_000,
    allocation_subjects: [
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::BIOLOGY,
    ],
  ),
  OpenStruct.new(
    training_route: :school_direct_tuition_fee,
    amount: 15_000,
    allocation_subjects: [
      AllocationSubjects::ENGLISH,
    ],
  ),
].freeze
