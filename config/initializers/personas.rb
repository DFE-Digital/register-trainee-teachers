# frozen_string_literal: true

PROVIDER_A = "Londinium Teacher Training"
PROVIDER_B = "North County SCITT"
PROVIDER_C = "University of BAT"

PERSONAS = [
  { first_name: "Agatha", last_name: "Baker", email: "agatha_baker@example.org", system_admin: true },
  { first_name: "Annie", last_name: "Bell", email: "annie_bell@example.org", provider: PROVIDER_A, system_admin: false },
  { first_name: "Damian", last_name: "Campbell", email: "damian_campbell@example.org", provider: PROVIDER_B, system_admin: false },
  { first_name: "Denise", last_name: "Theominis", email: "denise_theominis@example.org", provider: PROVIDER_B, system_admin: false, training_partner: true },
  { first_name: "Emma", last_name: "Smith", email: "emma_smith@example.org", provider: PROVIDER_C, system_admin: false, training_partner: true },
].push((DEVELOPER_PERSONA if defined?(DEVELOPER_PERSONA))).compact.freeze

PERSONA_EMAILS = PERSONAS.map { |persona| persona[:email] }
PERSONA_IDS = defined?(SANITISED_DATA_USERS_IDS_PERSONA) ? SANITISED_DATA_USERS_IDS_PERSONA : []
