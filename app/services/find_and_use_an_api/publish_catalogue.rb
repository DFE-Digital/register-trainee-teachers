# frozen_string_literal: true

module FindAndUseAnApi
  class PublishCatalogue
    include ServicePattern

    class Error < StandardError; end

    def call
      manifests = FindAndUseAnApi::BuildManifests.call
      raise(Error, "No OpenAPI versions found under public/openapi/") if manifests.empty?

      manifests.each { |manifest| publish_manifest!(manifest) }
    end

  private

    def publish_manifest!(manifest)
      major = manifest.fetch(:majorVersion)
      Rails.logger.info("Find and Use an API: importing #{Settings.fauapi.api_name} #{major} → #{Settings.fauapi.base_url}")

      FindAndUseAnApi::Client.import(manifest)
      api_id = find_entry_id!(major)
      FindAndUseAnApi::Client.publish(api_id)

      Rails.logger.info("Find and Use an API: published id=#{api_id} major=#{major}")
    end

    def find_entry_id!(major)
      matches = FindAndUseAnApi::Client.list_apis.select do |api|
        api["name"] == Settings.fauapi.api_name && api["majorVersion"] == major
      end

      case matches.size
      when 1
        matches.first.fetch("id")
      when 0
        raise(Error, "No catalogue entry for #{Settings.fauapi.api_name} (#{major}) after import")
      else
        ids = matches.map { |api| api["id"] }.join(", ")
        raise(Error, "Ambiguous catalogue entries for #{Settings.fauapi.api_name} (#{major}): ids #{ids}")
      end
    end
  end
end
