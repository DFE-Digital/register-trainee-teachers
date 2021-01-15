# frozen_string_literal: true

module Diversities
  NOT_PROVIDED = "Not provided"

  BANGLADESHI = "Bangladeshi"
  CHINESE = "Chinese"
  INDIAN = "Indian"
  PAKISTANI = "Pakistani"
  ANOTHER_ASIAN_BACKGROUND = "Another Asian background"

  AFRICAN = "African"
  CARIBBEAN = "Caribbean"
  ANOTHER_BLACK_BACKGROUND = "Another Black background"

  ASIAN_AND_WHITE = "Asian and White"
  BLACK_AFRICAN_AND_WHITE = "Black African and White"
  BLACK_CARIBBEAN_AND_WHITE = "Black Caribbean and White"
  ANOTHER_MIXED_BACKGROUND = "Another Mixed background"

  WHITE_BRITISH = "British, English, Northern Irish, Scottish, or Welsh"

  IRISH = "Irish"
  TRAVELLER_OR_GYPSY = "Traveller or Gypsy"
  ANOTHER_WHITE_BACKGROUND = "Another White background"

  ARAB = "Arab"
  ANOTHER_ETHNIC_BACKGROUND = "Another ethnic background"

  DIVERSITY_DISCLOSURE_ENUMS = {
    diversity_disclosed: "diversity_disclosed",
    diversity_not_disclosed: "diversity_not_disclosed",
  }.freeze

  DISABILITY_DISCLOSURE_ENUMS = {
    disabled: "disabled",
    no_disability: "no_disability",
    not_provided: "disability_not_provided",
  }.freeze

  ETHNIC_GROUP_ENUMS = {
    asian: "asian_ethnic_group",
    black: "black_ethnic_group",
    mixed: "mixed_ethnic_group",
    white: "white_ethnic_group",
    other: "other_ethnic_group",
    not_provided: "not_provided_ethnic_group",
  }.freeze

  BACKGROUNDS = {
    ETHNIC_GROUP_ENUMS[:asian] => [BANGLADESHI, CHINESE, INDIAN, PAKISTANI, ANOTHER_ASIAN_BACKGROUND],
    ETHNIC_GROUP_ENUMS[:black] => [AFRICAN, CARIBBEAN, ANOTHER_BLACK_BACKGROUND],
    ETHNIC_GROUP_ENUMS[:mixed] => [ASIAN_AND_WHITE, BLACK_AFRICAN_AND_WHITE, BLACK_CARIBBEAN_AND_WHITE, ANOTHER_MIXED_BACKGROUND],
    ETHNIC_GROUP_ENUMS[:white] => [WHITE_BRITISH, IRISH, TRAVELLER_OR_GYPSY, ANOTHER_WHITE_BACKGROUND],
    ETHNIC_GROUP_ENUMS[:other] => [ARAB, ANOTHER_ETHNIC_BACKGROUND],
  }.freeze

  OTHER = "Other"
  BLIND = "Blind"
  DEAF = "Deaf"
  LEARNING_DIFFICULTY = "Learning difficulty"
  LONG_STANDING_ILLNESS = "Long-standing illness"
  MENTAL_HEALTH_CONDITION = "Mental health condition"
  PHYSICAL_DISABILITY = "Physical disability or mobility issue"
  SOCIAL_IMPAIRMENT = "Social or communication impairment"

  # Internal only - DTTP related
  NO_KNOWN_DISABILITY = "No known disability"
  MULTIPLE_DISABILITIES = "Multiple disabilities"

  SEED_DISABILITIES = [
    OpenStruct.new(name: BLIND, description: "(or a serious visual impairment which is not corrected by glasses)"),
    OpenStruct.new(name: DEAF, description: "(or a serious hearing impairment)"),
    OpenStruct.new(name: LEARNING_DIFFICULTY, description: "(for example, dyslexia, dyspraxia or ADHD)"),
    OpenStruct.new(name: LONG_STANDING_ILLNESS, description: "(for example, cancer, HIV, diabetes, chronic heart disease or epilepsy)"),
    OpenStruct.new(name: MENTAL_HEALTH_CONDITION, description: "(for example, depression, schizophrenia or anxiety disorder)"),
    OpenStruct.new(name: PHYSICAL_DISABILITY, description: "(for example,impaired use of arms or legs, use of a wheelchair or crutches)"),
    OpenStruct.new(name: SOCIAL_IMPAIRMENT, description: "(for example Asperger’s, or another autistic spectrum disorder)"),
    OpenStruct.new(name: OTHER, description: nil),
  ].freeze
end
