# frozen_string_literal: true

module ExportsHelper
  VULNERABLE_CHARACTERS = %w[= + - @].freeze
  NEGATIVE_AMOUNT_PREFIX = %w[-£].freeze
  SAFE_NEGATIVE_AMOUNT_REGEX = /\A-{1}£{1}\d+\,?\d+\.?\d*\Z/

  def sanitize(value)
    return value unless value.is_a?(String)

    return value if value.to_s.starts_with?(*NEGATIVE_AMOUNT_PREFIX) && value.match?(SAFE_NEGATIVE_AMOUNT_REGEX)

    value.to_s.starts_with?(*VULNERABLE_CHARACTERS) ? "'#{value}" : value
  end

  def exceeds_export_limit?(current_user, filtered_trainees_count)
    current_user.system_admin? && filtered_trainees_count > Settings.trainee_export.record_limit
  end

  def itt_new_starter_trainees_count
    @itt_new_starter_trainees_count ||= itt_new_starter_trainees.count
  end
end
