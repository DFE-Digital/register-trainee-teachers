# frozen_string_literal: true

module ApiRequestHelpers
  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end
