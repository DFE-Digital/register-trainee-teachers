# frozen_string_literal: true

generate_openapi = ENV.fetch("OPENAPI", nil) == "1"

if generate_openapi
  seed = ENV.fetch("OPENAPI_SEED", 0xFFFF)
  srand(seed)
  Faker::Config.random = Random.new(seed) if defined? Faker

  RSpec.configure do |config|
    config.order = :defined

    version_regex = %r{spec/requests/api/v(?<major>\d+)_(?<minor>\d+)(?<label>_rc)?}
    match = ARGV.first.match(version_regex)
    version = "v#{match[:major]}.#{match[:minor]}#{match[:label] ? '-rc' : ''}"

    RSpec::OpenAPI.title = "Register API"
    RSpec::OpenAPI.application_version = version
    RSpec::OpenAPI.path = "public/openapi/#{version}.yaml"

    RSpec::OpenAPI.post_process_hook = lambda { |_path, _records, spec|
      spec[:paths].transform_keys! do |key|
        key.to_s.sub("{slug}", "{trainee_id}").gsub("_slug}", "_id}").to_sym
      end

      RSpec::OpenAPI::HashHelper.matched_paths(spec, "paths.*.*.parameters").each do |paths|
        spec.dig(*paths[0..]).replace(spec.dig(*paths[0..]).each do |parameters|
          parameters[:name] = "trainee_id" if parameters[:name] == "slug"
          parameters[:name] = parameters[:name].sub("_slug", "_id") if parameters[:name].include?("_slug")
        end)
      end
    }

    config.after(:suite) do
      puts
      puts "Generated api docs for version #{version}"
      puts "Generated file located: '#{RSpec::OpenAPI.path}'"
    end

    config.around do |example|
      time_sensitive = example.metadata[:time_sensitive]
      if time_sensitive
        example.run
      else
        time = Time.zone.local(current_academic_year, 9, 15, 12, 34, 56)
        Timecop.freeze(time)
        example.run
        Timecop.return
      end
    end
  end
end
