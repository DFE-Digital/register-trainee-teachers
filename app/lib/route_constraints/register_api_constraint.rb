# frozen_string_literal: true

module RouteConstraints
  class RegisterApiConstraint
    def self.matches?(request)
      Settings.api.allowed_versions.include?(request.path_parameters[:api_version])
    end
  end
end
