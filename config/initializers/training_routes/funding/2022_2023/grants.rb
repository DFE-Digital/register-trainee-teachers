# frozen_string_literal: true

GRANTS_2022_TO_2023 = [
  OpenStruct.new(
    training_route: :early_years_salaried,
    amount: 14_000,
    allocation_subjects: [
      AllocationSubjects::EARLY_YEARS_ITT,
    ],
  ),
  OpenStruct.new(
    training_route: :school_direct_salaried,
    amount: 24_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: :school_direct_salaried,
    amount: 15_000,
    allocation_subjects: [
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: :school_direct_salaried,
    amount: 10_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
    ],
  ),
  OpenStruct.new(
    training_route: :pg_teaching_apprenticeship,
    amount: 15_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: :pg_teaching_apprenticeship,
    amount: 6_000,
    allocation_subjects: [
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: :pg_teaching_apprenticeship,
    amount: 1_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
    ],
  ),
].freeze
