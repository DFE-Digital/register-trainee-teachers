# frozen_string_literal: true

PROVIDER_A = "Londinium Teacher Training"
PROVIDER_B = "North County SCITT"
PROVIDER_C = "University of BAT"

PERSONAS = [
  { first_name: "Agatha", last_name: "Baker", email: "agatha_baker@example.org", system_admin: true },

  { first_name: "Annie", last_name: "Bell", email: "annie_bell@example.org", provider: PROVIDER_A, system_admin: false },
  { first_name: "Jeffery", last_name: "Fahey", email: "jeffery_fahey@example.org", provider: PROVIDER_A, system_admin: false },
  { first_name: "Derek", last_name: "Lind", email: "derek_lind@example.org", provider: PROVIDER_A, system_admin: false },
  { first_name: "Mel", last_name: "Hamill", email: "mel_hamill@example.org", provider: PROVIDER_A, system_admin: false },
  { first_name: "Kyle", last_name: "Wunsch", email: "kyle_wunsch@example.org", provider: PROVIDER_A, system_admin: false },
  { first_name: "Stacie", last_name: "Bartoletti", email: "stacie_bartoletti@example.org", provider: PROVIDER_A, system_admin: false },
  { first_name: "Hugh", last_name: "Herzog", email: "hugh_herzog@example.org", provider: PROVIDER_A, system_admin: false },

  { first_name: "Damian", last_name: "Campbell", email: "damian_campbell@example.org", provider: PROVIDER_B, system_admin: false },
  { first_name: "Darren", last_name: "Russell", email: "darren_russell@example.org", provider: PROVIDER_B, system_admin: false },
  { first_name: "Jenny", last_name: "Gerhold", email: "jenny_gerhold@example.org", provider: PROVIDER_B, system_admin: false },
  { first_name: "Sue", last_name: "Murray", email: "sue_murray@example.org", provider: PROVIDER_B, system_admin: false },
  { first_name: "Eliza", last_name: "Grant", email: "eliza_grant@example.org", provider: PROVIDER_B, system_admin: false },
  { first_name: "Joanne", last_name: "Roberts", email: "joanne_roberts@example.org", provider: PROVIDER_B, system_admin: false },
  { first_name: "Megan", last_name: "Smith", email: "megan_smith@example.org", provider: PROVIDER_B, system_admin: false },

  { first_name: "Denise", last_name: "Theominis", email: "denise_theominis@example.org", provider: PROVIDER_B, system_admin: false, lead_school: true },
  { first_name: "Emma", last_name: "Smith", email: "emma_smith@example.org", provider: PROVIDER_C, system_admin: false, lead_school: true },
  { first_name: "Rose", last_name: "Wolf", email: "rose_wolf@example.org", provider: PROVIDER_C, system_admin: false, lead_school: true },
  { first_name: "Theo", last_name: "Harris", email: "theo_harris@example.org", provider: PROVIDER_C, system_admin: false, lead_school: true },
  { first_name: "John", last_name: "Hayes", email: "john_hayes@example.org", provider: PROVIDER_C, system_admin: false, lead_school: true },
  { first_name: "Max", last_name: "Brakus", email: "max_brakus@example.org", provider: PROVIDER_C, system_admin: false, lead_school: true },
  { first_name: "Paulo", last_name: "Styles", email: "paulo_styles@example.org", provider: PROVIDER_C, system_admin: false, lead_school: true },
  { first_name: "Ester", last_name: "Herman", email: "ester_herman@example.org", provider: PROVIDER_C, system_admin: false, lead_school: true },
  { first_name: "Michael", last_name: "Hansen", email: "michael_hansen@example.org", provider: PROVIDER_C, system_admin: false, lead_school: true },
].push((DEVELOPER_PERSONA if defined?(DEVELOPER_PERSONA))).compact.freeze

PERSONA_EMAILS = PERSONAS.map { |persona| persona[:email] }
