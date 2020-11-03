module Diversities
  DIVERSITY_DISCLOSURE_ENUMS = {
    diversity_disclosed: "diversity_disclosed",
    diversity_not_disclosed: "diversity_not_disclosed",
  }.freeze

  DISABILITY_DISCLOSURE_ENUMS = {
    disabled: "disabled",
    not_disabled: "not_disabled",
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
    ETHNIC_GROUP_ENUMS[:asian] => ["Bangladeshi", "Chinese", "Indian", "Pakistani", "Another Asian background"],
    ETHNIC_GROUP_ENUMS[:black] => ["African", "Caribbean", "Another Black background"],
    ETHNIC_GROUP_ENUMS[:mixed] => ["Asian and White", "Black African and White", "Black Caribbean and White", "Another Mixed background"],
    ETHNIC_GROUP_ENUMS[:white] => ["British, English, Northern Irish, Scottish, or Welsh", "Irish", "Irish Traveller or Gypsy", "Another White background"],
    ETHNIC_GROUP_ENUMS[:other] => ["Arab", "Another ethnic background"],
  }.freeze

  NOT_PROVIDED_VALUE = "Not provided".freeze

  SEED_DISABILITIES = [
    OpenStruct.new(name: "Blind", description: "(or a serious visual impairment which is not corrected by glasses)"),
    OpenStruct.new(name: "Deaf", description: "(or a serious hearing impairment)"),
    OpenStruct.new(name: "Learning difficulty", description: "(for example, dyslexia, dyspraxia or ADHD)"),
    OpenStruct.new(name: "Long-standing illness", description: "(for example, cancer, HIV, diabetes, chronic heart disease or epilepsy)"),
    OpenStruct.new(name: "Mental health condition", description: "(for example, depression, schizophrenia or anxiety disorder)"),
    OpenStruct.new(name: "Physical disability or mobility issue", description: "(for example,impaired use of arms or legs, use of a wheelchair or crutches)"),
    OpenStruct.new(name: "Social or communication impairment", description: "(for example Asperger’s, or another autistic spectrum disorder)"),
    OpenStruct.new(name: "Other", description: nil),
  ].freeze
end
