# frozen_string_literal: true

module ApiHelper
  def json_headers
    {
      "ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json",
    }.merge(enhanced_errors_headers)
  end

private

  def enhanced_errors_headers
    return {} unless defined?(enhanced_errors) && enhanced_errors

    {
      "ENHANCED_ERRORS" => "true",
    }
  end
end
