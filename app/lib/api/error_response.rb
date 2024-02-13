# frozen_string_literal: true

module Api
  module ErrorResponse
    def validation_errors_response(errors:)
      error_responses = errors.full_messages.map { |message| { error: "UnprocessableEntity", message: message } }

      {
        status: :unprocessable_entity, json: {
          errors: error_responses,
        }
      }
    end

    def transition_error_response(model_name: "trainee")
      {
        status: :unprocessable_entity, json: {
          errors: errors("StateTransitionError",
                         "It's not possible to perform this action while the #{model_name} is in its current state"),
        }
      }
    end

    def not_found_response(message:)
      {
        status: :not_found, json: {
          errors: errors("NotFound", message),
        }
      }
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
