# frozen_string_literal: true

module RouteConstraints
  class RegisterApiConstraint
    AVAILABLE_VERSIONS = ["v0.1", "v1.0-pre", "v2025.0-rc"].freeze

    def self.matches?(request)
      redirect_pre_release_requests_to_release_canidiate(request)

      AVAILABLE_VERSIONS.include?(request.path_parameters[:api_version])
    end

    def self.redirect_pre_release_requests_to_release_canidiate(request)
      request.path_parameters[:api_version] = "v2025.0-rc" if request.path_parameters[:api_version] == "v1.0-pre"
    end
  end
end
