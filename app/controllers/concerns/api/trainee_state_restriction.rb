# frozen_string_literal: true

module Api
  module TraineeStateRestriction
    extend ActiveSupport::Concern

    RESTRICTED_STATES = %w[recommended_for_award withdrawn awarded].freeze

  private

    def restrict_awarded_trainee_modification!
      if RESTRICTED_STATES.include?(trainee.state)
        render(**transition_error_response)
      end
    end
  end
end
