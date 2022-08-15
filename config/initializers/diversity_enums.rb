# frozen_string_literal: true

module Diversities
  NOT_PROVIDED = "Not provided"
  INFORMATION_REFUSED = "information_refused"
  INFORMATION_NOT_YET_SOUGHT = "information_not_yet_sought"

  WHITE = "white"
  SCOTTISH = "scottish"

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
  IRISH_TRAVELLER = "Irish traveller"
  TRAVELLER_OR_GYPSY = "Traveller or Gypsy"
  ROMA = "Roma"
  ANOTHER_WHITE_BACKGROUND = "Another White background"

  ARAB = "Arab"
  ANOTHER_ETHNIC_BACKGROUND = "Another ethnic background"

  NOT_PROVIDED_ETHNICITIES = [
    NOT_PROVIDED,
    INFORMATION_REFUSED,
    INFORMATION_NOT_YET_SOUGHT,
  ].freeze

  WHITE_ETHNICITIES = [
    WHITE,
    SCOTTISH,
  ].freeze

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
    ETHNIC_GROUP_ENUMS[:white] => [WHITE_BRITISH, IRISH, TRAVELLER_OR_GYPSY, ROMA, ANOTHER_WHITE_BACKGROUND],
    ETHNIC_GROUP_ENUMS[:other] => [ARAB, ANOTHER_ETHNIC_BACKGROUND],
  }.freeze

  ANOTHER_BACKGROUND = {
    ETHNIC_GROUP_ENUMS[:asian] => ANOTHER_ASIAN_BACKGROUND,
    ETHNIC_GROUP_ENUMS[:black] => ANOTHER_BLACK_BACKGROUND,
    ETHNIC_GROUP_ENUMS[:mixed] => ANOTHER_MIXED_BACKGROUND,
    ETHNIC_GROUP_ENUMS[:white] => ANOTHER_WHITE_BACKGROUND,
    ETHNIC_GROUP_ENUMS[:other] => ANOTHER_ETHNIC_BACKGROUND,
  }.freeze

  OTHER = "Other"
  BLIND = "Blind"
  DEAF = "Deaf"
  DEVELOPMENT_CONDITION = "Development condition"
  LEARNING_DIFFICULTY = "Learning difficulty"
  LONG_STANDING_ILLNESS = "Long-standing illness"
  MENTAL_HEALTH_CONDITION = "Mental health condition"
  PHYSICAL_DISABILITY = "Physical disability or mobility issue"
  SOCIAL_IMPAIRMENT = "Social or communication impairment"

  # Internal only - DTTP related
  NO_KNOWN_DISABILITY = "No known disability"
  MULTIPLE_DISABILITIES = "Multiple disabilities"

  SEED_DISABILITIES = [
    { name: BLIND, description: "Or a serious visual impairment which is not corrected by glasses" },
    { name: DEAF, description: "Or a serious hearing impairment" },
    { name: DEVELOPMENT_CONDITION, description: "A condition had since childhood which affects motor, cognitive, social and emotional skills, and speech and language" },
    { name: LEARNING_DIFFICULTY, description: "For example, dyslexia, dyspraxia or ADHD" },
    { name: LONG_STANDING_ILLNESS, description: "For example, cancer, HIV, diabetes, chronic heart disease or epilepsy" },
    { name: MENTAL_HEALTH_CONDITION, description: "For example, depression, schizophrenia or anxiety disorder" },
    { name: PHYSICAL_DISABILITY, description: "For example, impaired use of arms or legs, use of a wheelchair or crutches" },
    { name: SOCIAL_IMPAIRMENT, description: "For example a speech and language impairment or an autistic spectrum condition" },
    { name: OTHER, description: nil },
  ].freeze
end
