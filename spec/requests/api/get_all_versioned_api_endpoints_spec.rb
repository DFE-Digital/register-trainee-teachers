# frozen_string_literal: true

require "rails_helper"

paths_to_exclude = ["/api-docs/:api_version/openapi",
                    "/api-docs/:api_version/reference",
                    "/api/:api_version/info"]

paths = Rails.application.routes.routes.select { |route| route.verb == "GET" && route.parts.include?(:api_version) }
  .map { |route| route.path.spec.to_s.gsub("(.:format)", "") }
  .select { |path| paths_to_exclude.exclude?(path) }

describe "GET all versioned api endpoints" do
  context "Version v2025.0" do
    paths.each do |path|
      it_behaves_like "register versioned api GET request", "v2025.0", path, true
    end
  end
end
