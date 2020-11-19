# frozen_string_literal: true

class Persona < User
  default_scope { where(email: PERSONA_EMAILS) }
end
