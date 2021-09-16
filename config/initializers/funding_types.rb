# frozen_string_literal: true

FUNDING_TYPE_ENUMS = {
  bursary: "bursary",
  scholarship: "scholarship",
}.freeze

FUNDING_TYPES = {
  FUNDING_TYPE_ENUMS[:bursary] => 0,
  FUNDING_TYPE_ENUMS[:scholarship] => 1,
}.freeze
