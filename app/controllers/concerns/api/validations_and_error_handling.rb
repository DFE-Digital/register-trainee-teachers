# frozen_string_literal: true

module Api
  module ValidationsAndErrorHandling
    extend ActiveSupport::Concern
    include Api::ErrorResponse

    def render_not_found(message: "Not found")
      render(**not_found_response(message:))
    end
  end
end
