# frozen_string_literal: true

BURSARY_TIER_ENUMS = {
  tier_one: "tier_one",
  tier_two: "tier_two",
  tier_three: "tier_three",
}.freeze

BURSARY_TIERS = {
  BURSARY_TIER_ENUMS[:tier_one] => 1,
  BURSARY_TIER_ENUMS[:tier_two] => 2,
  BURSARY_TIER_ENUMS[:tier_three] => 3,
}.freeze
