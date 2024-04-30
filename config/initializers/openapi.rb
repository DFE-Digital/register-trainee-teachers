# frozen_string_literal: true

require "rspec/openapi"

RSpec::OpenAPI.title = "Send Trainee Data Direct API"

RSpec::OpenAPI.path = lambda { |example|
  if (match = example.file_path.match(%r{spec/requests/api/(v\d+\.\d+)/}))
    "public/openapi/#{match[1]}.yaml"
  end
}
