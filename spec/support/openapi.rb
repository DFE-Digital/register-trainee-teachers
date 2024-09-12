# frozen_string_literal: true

RSpec.configure do |config|
  generate_openapi = ENV.fetch("OPENAPI", nil) == "1"

  if generate_openapi
    version_regex = %r{spec/requests/api/v(?<major>\d+)_(?<minor>\d+)(?<label>_pre)?}
    match = ARGV.first.match(version_regex)
    version = "v#{match[:major]}.#{match[:minor]}#{match[:label] ? '-pre' : ''}"

    RSpec::OpenAPI.title = "Register API"
    RSpec::OpenAPI.application_version = version
    RSpec::OpenAPI.path = "public/openapi/#{version}.yaml"

    RSpec::OpenAPI.post_process_hook = lambda { |_path, _records, spec|
      spec[:paths].transform_keys! do |key|
        key.to_s.sub("{trainee_slug}", "{trainee_id}").sub("{slug}", "{id}").to_sym
      end

      RSpec::OpenAPI::HashHelper.matched_paths(spec, "paths.*.*.parameters").each do |paths|
        spec.dig(*paths[0..]).replace(spec.dig(*paths[0..]).each do |parameters|
          parameters[:name] = "trainee_id" if parameters[:name] == "trainee_slug"
          parameters[:name] = "id" if parameters[:name] == "slug"
        end)
      end
    }

    config.after(:suite) do
      puts
      puts "Generated api docs for version #{version}"
      puts "Generated file located: '#{RSpec::OpenAPI.path}'"
    end
  end
end
