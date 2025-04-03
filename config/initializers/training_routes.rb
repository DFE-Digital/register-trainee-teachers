# frozen_string_literal: true

TRAINING_ROUTE_ENUMS = {
  assessment_only: "assessment_only",
  early_years_assessment_only: "early_years_assessment_only",
  early_years_postgrad: "early_years_postgrad",
  early_years_salaried: "early_years_salaried",
  early_years_undergrad: "early_years_undergrad",
  iqts: "iqts",
  opt_in_undergrad: "opt_in_undergrad",
  provider_led_postgrad: "provider_led_postgrad",
  provider_led_undergrad: "provider_led_undergrad",
  school_direct_tuition_fee: "school_direct_tuition_fee",
  school_direct_salaried: "school_direct_salaried",
  pg_teaching_apprenticeship: "pg_teaching_apprenticeship",
  hpitt_postgrad: "hpitt_postgrad",
  teacher_degree_apprenticeship: "teacher_degree_apprenticeship",
}.freeze

TRAINING_ROUTE_TYPES = {
  postgrad_funded: [
    TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    TRAINING_ROUTE_ENUMS[:early_years_postgrad],
  ],
  postgrad_salaried: [
    TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    TRAINING_ROUTE_ENUMS[:early_years_salaried],
    TRAINING_ROUTE_ENUMS[:hpitt_postgrad],
  ],
  undergrad_funded: [
    TRAINING_ROUTE_ENUMS[:provider_led_undergrad],
    TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
    TRAINING_ROUTE_ENUMS[:early_years_undergrad],
  ],
  other: [
    TRAINING_ROUTE_ENUMS[:assessment_only],
    TRAINING_ROUTE_ENUMS[:early_years_assessment_only],
    TRAINING_ROUTE_ENUMS[:iqts],
    TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship],
  ],
}.freeze

ROUTE_INITIATIVES_ENUMS = {
  transition_to_teach: "transition_to_teach",
  troops_to_teachers: "troops_to_teachers",
  now_teach: "now_teach",
  maths_physics_chairs_programme_researchers_in_schools: "maths_physics_chairs_programme_researchers_in_schools",
  future_teaching_scholars: "future_teaching_scholars",
  no_initiative: "no_initiative",
  veterans_teaching_undergraduate_bursary: "veterans_teaching_undergraduate_bursary",
  international_relocation_payment: "international_relocation_payment",
  abridged_itt_course: "abridged_itt_course",
  primary_mathematics_specialist: "primary_mathematics_specialist",
  additional_itt_place_for_pe_with_a_priority_subject: "additional_itt_place_for_pe_with_a_priority_subject",
}.freeze

TRAINING_ROUTES = {
  TRAINING_ROUTE_ENUMS[:assessment_only] => 0,
  TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => 1,
  TRAINING_ROUTE_ENUMS[:early_years_undergrad] => 2,
  TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => 3,
  TRAINING_ROUTE_ENUMS[:school_direct_salaried] => 4,
  TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] => 5,
  TRAINING_ROUTE_ENUMS[:early_years_assessment_only] => 6,
  TRAINING_ROUTE_ENUMS[:early_years_salaried] => 7,
  TRAINING_ROUTE_ENUMS[:early_years_postgrad] => 8,
  TRAINING_ROUTE_ENUMS[:provider_led_undergrad] => 9,
  TRAINING_ROUTE_ENUMS[:opt_in_undergrad] => 10,
  TRAINING_ROUTE_ENUMS[:hpitt_postgrad] => 11,
  TRAINING_ROUTE_ENUMS[:iqts] => 12,
  TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship] => 14,
}.freeze

ROUTE_INITIATIVES = {
  ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars] => 0,
  ROUTE_INITIATIVES_ENUMS[:maths_physics_chairs_programme_researchers_in_schools] => 1,
  ROUTE_INITIATIVES_ENUMS[:now_teach] => 2,
  ROUTE_INITIATIVES_ENUMS[:transition_to_teach] => 3,
  ROUTE_INITIATIVES_ENUMS[:no_initiative] => 4,
  ROUTE_INITIATIVES_ENUMS[:troops_to_teachers] => 5,
  ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary] => 6,
  ROUTE_INITIATIVES_ENUMS[:international_relocation_payment] => 7,
  ROUTE_INITIATIVES_ENUMS[:abridged_itt_course] => 8,
  ROUTE_INITIATIVES_ENUMS[:primary_mathematics_specialist] => 9,
  ROUTE_INITIATIVES_ENUMS[:additional_itt_place_for_pe_with_a_priority_subject] => 10,
}.freeze

TRAINING_ROUTES_FOR_COURSE = TRAINING_ROUTES.select { |training_route|
  TRAINING_ROUTE_ENUMS.values_at(:provider_led_postgrad,
                                 :school_direct_tuition_fee,
                                 :school_direct_salaried,
                                 :pg_teaching_apprenticeship).include?(training_route)
}.freeze

UNDERGRAD_ROUTES = TRAINING_ROUTES.select { |training_route|
  TRAINING_ROUTE_ENUMS.values_at(:early_years_undergrad, :provider_led_undergrad, :opt_in_undergrad, :teacher_degree_apprenticeship).include?(training_route)
}.freeze

PLACEMENTS_ROUTES = TRAINING_ROUTES.select { |training_route|
  TRAINING_ROUTE_ENUMS.values_at(:assessment_only, :early_years_assessment_only).exclude?(training_route)
}.freeze

LEAD_PARTNER_ROUTES = %i[
  school_direct_salaried
  school_direct_tuition_fee
  pg_teaching_apprenticeship
  provider_led_postgrad
  provider_led_undergrad
  early_years_salaried
  early_years_undergrad
  iqts
  teacher_degree_apprenticeship
].freeze
EMPLOYING_SCHOOL_ROUTES = %i[
  school_direct_salaried
  pg_teaching_apprenticeship
  early_years_salaried
  teacher_degree_apprenticeship
].freeze

TRAINING_ROUTE_FEATURE_FLAGS = TRAINING_ROUTE_ENUMS.keys.reject { |training_route|
  %i[assessment_only].include?(training_route)
}.freeze

QTS_AWARD_TYPE = "QTS"
EYTS_AWARD_TYPE = "EYTS"

TRAINING_ROUTE_AWARD_TYPE = {
  assessment_only: QTS_AWARD_TYPE,
  early_years_undergrad: EYTS_AWARD_TYPE,
  early_years_salaried: EYTS_AWARD_TYPE,
  early_years_postgrad: EYTS_AWARD_TYPE,
  early_years_assessment_only: EYTS_AWARD_TYPE,
  pg_teaching_apprenticeship: QTS_AWARD_TYPE,
  provider_led_postgrad: QTS_AWARD_TYPE,
  provider_led_undergrad: QTS_AWARD_TYPE,
  school_direct_salaried: QTS_AWARD_TYPE,
  provider_led_postgrad_salaried: QTS_AWARD_TYPE,
  school_direct_tuition_fee: QTS_AWARD_TYPE,
  opt_in_undergrad: QTS_AWARD_TYPE,
  hpitt_postgrad: QTS_AWARD_TYPE,
  iqts: QTS_AWARD_TYPE,
  teacher_degree_apprenticeship: QTS_AWARD_TYPE,
}.freeze

EARLY_YEARS_ROUTE_NAME_PREFIX = "early_years"

EARLY_YEARS_TRAINING_ROUTES = TRAINING_ROUTES.select { |t| t.starts_with?(EARLY_YEARS_ROUTE_NAME_PREFIX) }

# Training route groupings
POSTGRAD_FUNDED = "Postgrad (fee funded)"
POSTGRAD_SALARIED = "Postgrad (salaried)"
UNDERGRAD_FUNDED = "Undergrad (fee funded)"
OTHER = "Other"

# 2021 funding rules (which also applied to 2022)

BURSARIES_2020_TO_2021 = [
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
    amount: 24_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 10_000,
    allocation_subjects: [
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::CLASSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 7_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
      AllocationSubjects::GENERAL_SCIENCES,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 24_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 10_000,
    allocation_subjects: [
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::CLASSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 7_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
    amount: 9_000,
    allocation_subjects: [
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MODERN_LANGUAGES,
    ],
  ),
].freeze

SCHOLARSHIPS_2020_TO_2021 = [
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 26_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 26_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
].freeze

GRANTS_2020_TO_2021 = [
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:early_years_salaried],
    amount: 14_000,
    allocation_subjects: [
      AllocationSubjects::EARLY_YEARS_ITT,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 24_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 10_000,
    allocation_subjects: [
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::CLASSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 7_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 15_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 1_000,
    allocation_subjects: [
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::CLASSICS,
    ],
  ),
].freeze

BURSARIES_2021_TO_2022 = BURSARIES_2020_TO_2021
SCHOLARSHIPS_2021_TO_2022 = SCHOLARSHIPS_2020_TO_2021
GRANTS_2021_TO_2022 = GRANTS_2020_TO_2021

BURSARIES_2022_TO_2023 = [
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
    amount: 24_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 15_000,
    allocation_subjects: [
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 10_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 24_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 15_000,
    allocation_subjects: [
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 10_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
    amount: 9_000,
    allocation_subjects: [
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
].freeze

SCHOLARSHIPS_2022_TO_2023 = [
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 26_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 26_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
].freeze

GRANTS_2022_TO_2023 = [
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:early_years_salaried],
    amount: 14_000,
    allocation_subjects: [
      AllocationSubjects::EARLY_YEARS_ITT,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 24_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 15_000,
    allocation_subjects: [
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 10_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 15_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 6_000,
    allocation_subjects: [
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 1_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
    ],
  ),
].freeze

BURSARIES_2023_TO_2024 = [
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
    amount: 27_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 25_000,
    allocation_subjects: [
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 20_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 15_000,
    allocation_subjects: [
      AllocationSubjects::ENGLISH,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
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
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 27_000,
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
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 20_000,
    allocation_subjects: [
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::BIOLOGY,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 15_000,
    allocation_subjects: [
      AllocationSubjects::ENGLISH,
    ],
  ),
].freeze

SCHOLARSHIPS_2023_TO_2024 = [
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
    amount: 27_000,
    allocation_subjects: [
      AllocationSubjects::MODERN_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 29_000,
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
      AllocationSubjects::MODERN_LANGUAGES,
    ],
  ),
].freeze

GRANTS_2023_TO_2024 = [
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:early_years_postgrad],
    amount: 5_000,
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
    amount: 27_000,
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
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 20_000,
    allocation_subjects: [
      AllocationSubjects::BIOLOGY,
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
    amount: 15_000,
    allocation_subjects: [
      AllocationSubjects::ENGLISH,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 18_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 16_000,
    allocation_subjects: [
      AllocationSubjects::GEOGRAPHY,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::ANCIENT_LANGUAGES,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 11_000,
    allocation_subjects: [
      AllocationSubjects::DESIGN_AND_TECHNOLOGY,
      AllocationSubjects::BIOLOGY,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
    amount: 6_000,
    allocation_subjects: [
      AllocationSubjects::ENGLISH,
    ],
  ),
].freeze

BURSARIES_2024_TO_2025 = [
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
    amount: 28_000,
    allocation_subjects: [
      AllocationSubjects::CHEMISTRY,
      AllocationSubjects::COMPUTING,
      AllocationSubjects::MATHEMATICS,
      AllocationSubjects::PHYSICS,
    ],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
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
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 10_000,
    allocation_subjects: [
      AllocationSubjects::ART_AND_DESIGN,
      AllocationSubjects::ENGLISH,
      AllocationSubjects::MUSIC,
      AllocationSubjects::RELIGIOUS_EDUCATION,
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

SCHOLARSHIPS_2024_TO_2025 = [
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
