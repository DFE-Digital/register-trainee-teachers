# frozen_string_literal: true

TRAINING_ROUTE_ENUMS = {
  assessment_only: "assessment_only",
  early_years_assessment_only: "early_years_assessment_only",
  early_years_postgrad: "early_years_postgrad",
  early_years_salaried: "early_years_salaried",
  early_years_undergrad: "early_years_undergrad",
  pg_teaching_apprenticeship: "pg_teaching_apprenticeship",
  provider_led_postgrad: "provider_led_postgrad",
  school_direct_tuition_fee: "school_direct_tuition_fee",
  school_direct_salaried: "school_direct_salaried",
  provider_led_undergrad: "provider_led_undergrad",
  opt_in_undergrad: "opt_in_undergrad",
  hpitt_postgrad: "hpitt_postgrad",
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
}.freeze

TRAINING_ROUTES_FOR_TRAINEE = TRAINING_ROUTES.select { |training_route|
  TRAINING_ROUTE_ENUMS.values_at(:assessment_only, :provider_led_postgrad, :early_years_undergrad, :school_direct_tuition_fee, :school_direct_salaried, :early_years_assessment_only, :early_years_salaried, :early_years_postgrad).include? training_route
}.freeze

TRAINING_ROUTES_FOR_COURSE = TRAINING_ROUTES.select { |training_route|
  TRAINING_ROUTE_ENUMS.values_at(:provider_led_postgrad, :school_direct_tuition_fee, :school_direct_salaried, :pg_teaching_apprenticeship).include? training_route
}.freeze

TRAINING_ROUTE_FEATURE_FLAGS = TRAINING_ROUTE_ENUMS.keys.reject { |training_route|
  %i[assessment_only pg_teaching_apprenticeship].include? training_route
}.freeze

TRAINING_ROUTE_AWARD_TYPE = {
  assessment_only: "QTS",
  early_years_undergrad: "EYTS",
  early_years_salaried: "EYTS",
  early_years_postgrad: "EYTS",
  early_years_assessment_only: "EYTS",
  pg_teaching_apprenticeship: "QTS",
  provider_led_postgrad: "QTS",
  school_direct_salaried: "QTS",
  school_direct_tuition_fee: "QTS",
}.freeze

EARLY_YEARS_ROUTES = TRAINING_ROUTE_AWARD_TYPE.select { |_, v| v == "EYTS" }.keys.freeze

SEED_BURSARIES = [
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 24_000,
    allocation_subjects: %w[Chemistry Computing Mathematics Physics],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 10_000,
    allocation_subjects: ["Modern languages", "Classics"],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
    amount: 7_000,
    allocation_subjects: %w[Biology],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 24_000,
    allocation_subjects: %w[Chemistry Computing Mathematics Physics],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 10_000,
    allocation_subjects: ["Modern languages", "Classics"],
  ),
  OpenStruct.new(
    training_route: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
    amount: 7_000,
    allocation_subjects: %w[Biology],
  ),
].freeze

TRAINING_ROUTES_INITIATIVES = {
  TRAINING_ROUTE_ENUMS[:assessment_only] => ["Transition to Teach",
                                             "Now Teach"],
  TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => ["Transition to Teach",
                                                   "Now Teach",
                                                   "Maths & Physics Chairs Programme/Researchers in Schools"],
  TRAINING_ROUTE_ENUMS[:early_years_undergrad] => ["Transition to Teach",
                                                   "Now Teach"],
  TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => ["Transition to Teach",
                                                       "Now Teach",
                                                       "Maths & Physics Chairs Programme/Researchers in Schools"],
  TRAINING_ROUTE_ENUMS[:school_direct_salaried] => ["Future Teaching Scholars",
                                                    "Maths & Physics Chairs Programme/Researchers in Schools",
                                                    "Now Teach"],
  TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] => ["Transition to Teach",
                                                        "Now Teach"],
  TRAINING_ROUTE_ENUMS[:early_years_assessment_only] => ["Transition to Teach",
                                                         "Now Teach"],
  TRAINING_ROUTE_ENUMS[:early_years_salaried] => ["Transition to Teach",
                                                  "Now Teach"],
  TRAINING_ROUTE_ENUMS[:early_years_postgrad] => ["Transition to Teach",
                                                  "Now Teach"],
  TRAINING_ROUTE_ENUMS[:provider_led_undergrad] => ["Transition to Teach",
                                                    "Now Teach"],
  TRAINING_ROUTE_ENUMS[:opt_in_undergrad] => ["Transition to Teach",
                                              "Now Teach"],
  TRAINING_ROUTE_ENUMS[:hpitt_postgrad] => ["Transition to Teach",
                                            "Now Teach"],
}.freeze
