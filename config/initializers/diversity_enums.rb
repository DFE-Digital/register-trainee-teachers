module Diversities
  ENUMS = {
    asian: "asian_ethnic_group",
    black: "black_ethnic_group",
    mixed: "mixed_ethnic_group",
    white: "white_ethnic_group",
    other: "other_ethnic_group",
    not_provided: "no_ethnic_group_provided",
  }.freeze

  BACKGROUNDS = {
    ENUMS[:asian] => ["Bangladeshi", "Chinese", "Indian", "Pakistani", "Another Asian background"],
    ENUMS[:black] => ["African", "Caribbean", "Another Black background"],
    ENUMS[:mixed] => ["Asian and White", "Black African and White", "Black Caribbean and White", "Another Mixed background"],
    ENUMS[:white] => ["British, English, Northern Irish, Scottish, or Welsh", "Irish", "Irish Traveller or Gypsy", "Another White background"],
    ENUMS[:other] => ["Arab", "Another ethnic background"],
  }.freeze

  NOT_PROVIDED_VALUE = "Not provided".freeze
end
