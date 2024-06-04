# frozen_string_literal: true

module ApiHelper
  def json_headers
    {
      "ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json",
    }
  end
end
