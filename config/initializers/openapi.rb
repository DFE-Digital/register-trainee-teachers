# frozen_string_literal: true

require "rspec/openapi"

RSpec::OpenAPI.title = "Send Trainee Data Direct API"

RSpec::OpenAPI.path = -> (example) {
  if match = example.file_path.match(%r[spec/requests/api/(v\d+\.\d+)/])
    version = match[1]  # Capture the whole version string including 'v'
    "public/openapi/#{version}.yaml"
  else
    'public/openapi.yaml'  # Default path if no version pattern is matched
  end
}
