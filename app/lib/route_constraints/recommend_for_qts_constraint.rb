# frozen_string_literal: true

module RouteConstraints
  class RecommendForQtsConstraint
    VERSIONS = %w[v2026.1].freeze

    def self.matches?(request)
      VERSIONS.include?(request.path_parameters[:api_version])
    end
  end
end
