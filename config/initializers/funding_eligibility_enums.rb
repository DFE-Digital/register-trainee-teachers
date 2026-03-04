# frozen_string_literal: true

FUNDING_ELIGIBILITY_ENUMS = {
  eligible: "eligible",
  not_eligible: "not_eligible",
}.freeze

FUNDING_ELIGIBILITIES = {
  FUNDING_ELIGIBILITY_ENUMS[:eligible] => 0,
  FUNDING_ELIGIBILITY_ENUMS[:not_eligible] => 1,
}.freeze
