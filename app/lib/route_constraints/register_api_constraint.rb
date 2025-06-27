# frozen_string_literal: true

module RouteConstraints
  class RegisterApiConstraint
    AVAILABLE_VERSIONS = ["v2025.0-rc"].freeze

    def self.matches?(request)
      AVAILABLE_VERSIONS.include?(request.path_parameters[:api_version])
    end
  end
end
