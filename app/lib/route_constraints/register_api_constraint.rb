# frozen_string_literal: true

module RouteConstraints
  class RegisterApiConstraint
    def self.matches?(request)
      request.path_parameters[:api_version] == "v0.1"
    end
  end
end
