# frozen_string_literal: true

PROVIDER_A = "Provider A"
PROVIDER_B = "Provider B"

PERSONAS = [
  { first_name: "Adam", last_name: "Baker", email: "adam_baker@example.org", system_admin: true },
  { first_name: "Annie", last_name: "Bell", email: "annie_bell@example.org", provider: PROVIDER_A, system_admin: false },
  { first_name: "Bridget", last_name: "Campbell", email: "bridget_campbell@example.org", provider: PROVIDER_B, system_admin: false },
].freeze

PERSONA_EMAILS = PERSONAS.map { |persona| persona[:email] }
