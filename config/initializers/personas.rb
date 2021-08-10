# frozen_string_literal: true

PROVIDER_A = "Provider A"
PROVIDER_B = "Provider B"
PROVIDER_C = "Teach First"
TEACH_FIRST_PROVIDER_CODE = "HPPIT"

PERSONAS = [
  { first_name: "Adam", last_name: "Baker", email: "adam_baker@example.org", system_admin: true },
  { first_name: "Annie", last_name: "Bell", email: "annie_bell@example.org", provider: PROVIDER_A, system_admin: false },
  { first_name: "Bridget", last_name: "Campbell", email: "bridget_campbell@example.org", provider: PROVIDER_B, system_admin: false },
  { first_name: "Teach", last_name: "First", email: "teach_first@example.org", provider: PROVIDER_C, system_admin: false, provider_code: TEACH_FIRST_PROVIDER_CODE },
].freeze

PERSONA_EMAILS = PERSONAS.map { |persona| persona[:email] }
