# frozen_string_literal: true

module ExportsHelper
  VULNERABLE_CHARACTERS = %w[= + - @].freeze
  NEGATIVE_AMOUNT_PREFIX = %w[-£].freeze
  SAFE_NEGATIVE_AMOUNT_REGEX = /\A-{1}£{1}\d+\,?\d+\.?\d*\Z/.freeze

  def sanitize(value)
    return value unless value.is_a?(String)

    return value if value.to_s.starts_with?(*NEGATIVE_AMOUNT_PREFIX) && value.match?(SAFE_NEGATIVE_AMOUNT_REGEX)

    value.to_s.starts_with?(*VULNERABLE_CHARACTERS) ? "'#{value}" : value
  end
end
