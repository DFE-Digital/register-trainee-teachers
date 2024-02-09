# frozen_string_literal: true

module Api
  module ValidationsAndErrorHandling
    extend ActiveSupport::Concern

    def render_not_found(message: "Not found")
      render(status: :not_found, json: {
        errors: errors("NotFound", message),
      })
    end

    def render_validation_errors(errors:)
      error_responses = errors.full_messages.map { |message| { error: "UnprocessableEntity", message: message } }

      render(status: :unprocessable_entity, json: {
        errors: error_responses,
      })
    end

    def render_transition_error(model_name: "trainee")
      render(status: :unprocessable_entity, json: {
        errors: errors("StateTransitionError",
                       "It's not possible to perform this action while the #{model_name} is in its current state"),
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
