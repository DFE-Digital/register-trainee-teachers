# frozen_string_literal: true

TRAINING_ROUTE_TYPES = {
  postgrad_funded: %w[provider_led_postgrad early_years_postgrad],
  postgrad_salaried: %w[pg_teaching_apprenticeship early_years_salaried hpitt_postgrad],
  undergrad_funded: %w[provider_led_undergrad opt_in_undergrad early_years_undergrad],
  other: %w[assessment_only early_years_assessment_only iqts teacher_degree_apprenticeship],
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
  "assessment_only" => 0,
  "provider_led_postgrad" => 1,
  "early_years_undergrad" => 2,
  "school_direct_tuition_fee" => 3,
  "school_direct_salaried" => 4,
  "pg_teaching_apprenticeship" => 5,
  "early_years_assessment_only" => 6,
  "early_years_salaried" => 7,
  "early_years_postgrad" => 8,
  "provider_led_undergrad" => 9,
  "opt_in_undergrad" => 10,
  "hpitt_postgrad" => 11,
  "iqts" => 12,
  "teacher_degree_apprenticeship" => 14,
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
  %w[
    provider_led_postgrad
    provider_led_undergrad
    teacher_degree_apprenticeship
    school_direct_tuition_fee
    school_direct_salaried
    pg_teaching_apprenticeship
  ].include?(training_route)
}.freeze

UNDERGRAD_ROUTES = TRAINING_ROUTES.select { |training_route|
  %w[early_years_undergrad provider_led_undergrad opt_in_undergrad teacher_degree_apprenticeship].include?(training_route)
}.freeze

PLACEMENTS_ROUTES = TRAINING_ROUTES.select { |training_route|
  %w[assessment_only early_years_assessment_only].exclude?(training_route)
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

TRAINING_ROUTE_FEATURE_FLAGS = TRAINING_ROUTES.keys.reject { |training_route|
  %w[assessment_only].include?(training_route)
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
