# frozen_string_literal: true

module Api
  module ValidationsAndErrorHandling
    extend ActiveSupport::Concern

    def render_not_found(message: "Not found")
      render(status: :not_found, json: {
        errors: errors("NotFound", message),
      })
    end

    def render_parameter_invalid(parameter_keys:)
      render(status: :unprocessable_entity, json: {
        errors: errors("ParameterInvalid",
                       "Please ensure valid values are provided for #{parameter_keys.to_sentence}"),
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
