# frozen_string_literal: true

# https://owasp.org/www-community/attacks/CSV_Injection
class CsvValueSanitiser
  def initialize(value)
    @value = value
  end

  def safe?
    string_value = @value.to_s
    string_value.blank? ? true : string_value =~ /\A[^=+\-@\t\r]/
  end

  def sanitise
    safe_original_value_or_original_value_made_safe
  end

private

  def safe_original_value_or_original_value_made_safe
    safe? ? @value : convert
  end

  def convert
    wrap_in_double_quotes(replace_every_double_quote_with_two_double_quotes(prepend_with_a_single_quote(@value)))
  end

  def wrap_in_double_quotes(value)
    "\"#{value}\""
  end

  def prepend_with_a_single_quote(value)
    "'#{value}"
  end

  def replace_every_double_quote_with_two_double_quotes(value)
    value.gsub('"', '""')
  end
end
