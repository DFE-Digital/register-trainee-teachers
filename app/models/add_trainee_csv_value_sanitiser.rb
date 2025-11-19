# frozen_string_literal: true

# https://owasp.org/www-community/attacks/CSV_Injection
class AddTraineeCsvValueSanitiser < CsvValueSanitiser
  def initialize(key, value)
    @key = key
    super(value)
  end

  def safe?
    super &&
      (!@key.in?(BulkUpdate::AddTrainees::VERSION::ImportRows::PREFIXED_HEADERS) ||
      @value.blank? ||
      @value.start_with?("'"))
  end

  def wrap_in_double_quotes(value)
    value
  end
end
