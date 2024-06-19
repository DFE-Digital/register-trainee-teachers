# frozen_string_literal: true

require "rspec/openapi"

RSpec::OpenAPI.title = "Register API"

RSpec::OpenAPI.path = lambda { |example|
  if (match = example.file_path.match(%r{spec/requests/api/(v\d+\_\d+)/}))
    version = match[1].gsub("_", ".")

    "public/openapi/#{version}.yaml"
  end
}
