# frozen_string_literal: true

module Api
  module TraineeStateRestriction
    extend ActiveSupport::Concern

    UNRESTRICTED_VERSIONS = %w[v2025.0-rc v2025.0 v2026.0].freeze
    RESTRICTED_STATES = %w[recommended_for_award awarded].freeze

  private

    def restrict_awarded_trainee_modification!
      return if UNRESTRICTED_VERSIONS.include?(version)

      if RESTRICTED_STATES.include?(trainee.state)
        render(**transition_error_response)
      end
    end
  end
end
