module Diversities
  DIVERSITY_DISCLOSURE_ENUMS = {
    diversity_disclosed: "diversity_disclosed",
    diversity_not_disclosed: "diversity_not_disclosed",
  }.freeze

  ETHNIC_GROUP_ENUMS = {
    asian: "asian_ethnic_group",
    black: "black_ethnic_group",
    mixed: "mixed_ethnic_group",
    white: "white_ethnic_group",
    other: "other_ethnic_group",
    not_provided: "no_ethnic_group_provided",
  }.freeze

  BACKGROUNDS = {
    ETHNIC_GROUP_ENUMS[:asian] => ["Bangladeshi", "Chinese", "Indian", "Pakistani", "Another Asian background"],
    ETHNIC_GROUP_ENUMS[:black] => ["African", "Caribbean", "Another Black background"],
    ETHNIC_GROUP_ENUMS[:mixed] => ["Asian and White", "Black African and White", "Black Caribbean and White", "Another Mixed background"],
    ETHNIC_GROUP_ENUMS[:white] => ["British, English, Northern Irish, Scottish, or Welsh", "Irish", "Irish Traveller or Gypsy", "Another White background"],
    ETHNIC_GROUP_ENUMS[:other] => ["Arab", "Another ethnic background"],
  }.freeze

  NOT_PROVIDED_VALUE = "Not provided".freeze
end
