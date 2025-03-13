# frozen_string_literal: true

require "rails_helper"

paths_to_exclude = ["/api-docs/:api_version/openapi",
                    "/api-docs/:api_version/reference",
                    "/api-docs/:api_version/hesa-reference",
                    "/api-docs/:api_version/hesa-reference/trainee/:attribute",
                    "/api-docs/:api_version/hesa-reference/degree/:attribute",
                    "/api/:api_version/info"]

paths = Rails.application.routes.routes.select { |route| route.verb == "GET" && route.parts.include?(:api_version) }
  .map { |route| route.path.spec.to_s.gsub("(.:format)", "") }
  .select { |path| paths_to_exclude.exclude?(path) }

describe "GET all versioned api endpoints" do
  context "Version v0.1" do
    paths.each do |path|
      include_examples "register versioned api GET request", "v0.1", path, true
    end
  end

  context "Version v1.0-pre" do
    paths.each do |path|
      include_examples "register versioned api GET request", "v1.0-pre", path, true
    end
  end
end
