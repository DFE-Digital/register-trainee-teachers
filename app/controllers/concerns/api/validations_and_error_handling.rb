# frozen_string_literal: true

module Api
  module ValidationsAndErrorHandling
    extend ActiveSupport::Concern

    def render_not_found(message: "Not found")
      render(status: :not_found, json: {
        errors: errors("NotFound", message),
      })
    end

  private

    def errors(error, message)
      [
        {
          error:,
          message:,
        },
      ]
    end
  end
end
