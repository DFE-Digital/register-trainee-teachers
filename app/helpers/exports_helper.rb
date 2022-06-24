# frozen_string_literal: true

module ExportsHelper
  VULNERABLE_CHARACTERS = %w[= + - @].freeze

  def sanitize(value)
    return value unless value.is_a?(String)

    value.to_s.starts_with?(*VULNERABLE_CHARACTERS) ? value.to_s : value
  end
end
