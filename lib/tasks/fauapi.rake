# frozen_string_literal: true

namespace :fauapi do
  desc "Generate the FauAPI manifest from current API version settings"
  task generate: :environment do
    current_version = Settings.api.current_version
    major_version = current_version.split(".").first

    schema_url = "https://raw.githubusercontent.com/DFE-Digital/register-trainee-teachers/refs/heads/main/public/openapi/#{current_version}.yaml"

    openapi_files = Dir.glob(Rails.root.join("public/openapi/v*.yaml")).sort
    releases = openapi_files.map do |file|
      version = File.basename(file, ".yaml")
      is_current = version == current_version
      year = version.match(/v(\d{4})/)[1].to_i

      {
        isCurrent: is_current,
        name: version,
        tag: is_current ? "Live" : "Planned",
        availableFrom: "#{year}-09-01",
        notes: is_current ? "Current release of the Register API." : "Planned release of the Register API.",
      }
    end

    manifest = {
      name: "register-trainee-teachers-api",
      displayName: "Register Trainee Teachers API",
      description: "Register Public API for ITT Providers, SRS Vendors and HEIs to register trainee teachers",
      overview: "Register API Public Interface\r\nFull documentation is available here:\r\n[Register API documentation - Register trainee teachers](https://www.register-trainee-teachers.service.gov.uk/api-docs)",
      schemaUrl: schema_url,
      schemaType: "openapi",
      siteUrl: "https://www.register-trainee-teachers.service.gov.uk/api-docs",
      backendType: "http",
      majorVersion: major_version,
      visibility: "Internal",
      tags: "register;api;itt",
      classification: "Public facing",
      serviceLevel: "24/7",
      technology: "REST, Ruby on Rails",
      usage: "ITT Providers, SRS Vendors and HEIs",
      environments: [
        { name: "dev", baseUrl: "https://sandbox.register-trainee-teachers.service.gov.uk", visibility: "Public", enabled: true, backendMode: "None" },
        { name: "staging", baseUrl: "https://staging.register-trainee-teachers.service.gov.uk", visibility: "Internal", enabled: true, backendMode: "None" },
        { name: "live", baseUrl: "https://www.register-trainee-teachers.service.gov.uk", visibility: "Public", enabled: true, backendMode: "None" },
      ],
      releases: releases,
    }

    output_path = Rails.root.join("public/fauapi/register-api.json")
    FileUtils.mkdir_p(File.dirname(output_path))
    File.write(output_path, JSON.pretty_generate(manifest) + "\n")

    puts "Generated FauAPI manifest at #{output_path}"
    puts "  schemaUrl: #{schema_url}"
    puts "  majorVersion: #{major_version}"
    puts "  releases: #{releases.map { |r| "#{r[:name]} (#{r[:tag]})" }.join(', ')}"
  end
end
