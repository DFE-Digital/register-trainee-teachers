# frozen_string_literal: true

module FindAndUseAnApi
  class BuildManifests
    include ServicePattern

    ENVIRONMENTS = [
      { name: "dev", backendUrl: "https://sandbox.register-trainee-teachers.service.gov.uk", visibility: "Public", enabled: true, backendMode: "None" },
      { name: "live", backendUrl: "https://www.register-trainee-teachers.service.gov.uk", visibility: "Public", enabled: true, backendMode: "None" },
    ].freeze

    def call
      current_version = Settings.api.current_version

      versions_by_major = Rails.root.glob("public/openapi/v*.yaml")
        .map { |path| File.basename(path, ".yaml") }
        .group_by { |version| major_of(version) }

      versions_by_major.keys.sort_by { |major| version_key(major) }.map do |major|
        versions = versions_by_major[major].sort_by { |version| version_key(version) }
        entry_version = versions.include?(current_version) ? current_version : versions.last
        schema_file = "#{entry_version}.yaml"
        schema_bytes = Rails.public_path.join("openapi", schema_file).binread

        {
          name: Settings.fauapi.api_name,
          displayName: "Register trainee teachers API",
          description: "The Register API allows providers to import trainee records from their student record systems and to keep those records synchronised as they are modified.",
          overview: "Register API Public Interface\r\nFull documentation is available here:\r\n[Register API documentation - Register trainee teachers](https://www.register-trainee-teachers.service.gov.uk/api-docs)",
          siteUrl: "https://www.register-trainee-teachers.service.gov.uk/api-docs",
          backendType: "http",
          majorVersion: major,
          visibility: "Public",
          tags: "register;api;itt",
          classification: "Public facing",
          serviceLevel: "24/7",
          technology: "REST, Ruby on Rails",
          usage: "HEI ITT providers and SRS vendors",
          environments: ENVIRONMENTS,
          releases: versions.map do |version|
            tag = release_tag(version, current_version)
            {
              isCurrent: version == entry_version,
              name: version,
              tag: tag,
              notes: "#{tag} release of the Register API.",
            }
          end,
          schema: {
            fileName: schema_file,
            name: entry_version,
            schemaType: "openapi",
            contentType: "application/yaml",
            documentContentValue: Base64.strict_encode64(schema_bytes),
          },
        }
      end
    end

  private

    def version_key(version)
      version.delete_prefix("v").split(".").map(&:to_i)
    end

    def major_of(version)
      version.split(".").first
    end

    def release_tag(version, current_version)
      case version_key(version) <=> version_key(current_version)
      when 0 then "Live"
      when 1 then "Planned"
      else "Deprecated"
      end
    end
  end
end
