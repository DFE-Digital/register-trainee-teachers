# frozen_string_literal: true

module RouteConstraints
  class RegisterApiConstraint
    AVAILABLE_VERSIONS = ["v2025.0", "v2025.0-rc"].freeze

    def self.matches?(request)
      redirect_release_candidate_requests_to_api(request)

      AVAILABLE_VERSIONS.include?(request.path_parameters[:api_version])
    end

    def self.redirect_release_candidate_requests_to_api(request)
      request.path_parameters[:api_version] = "v2025.0" if request.path_parameters[:api_version] == "v2025.0-rc" && request.path_parameters[:controller] != "api/info"
    end
  end
end
