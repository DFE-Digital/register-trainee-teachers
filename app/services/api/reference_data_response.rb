# frozen_string_literal: true

module Api
  class ReferenceDataResponse < BaseService
    class UnsupportedVersionError < StandardError; end

    SUPPORTED_FROM = "v2026.1"

    def initialize(version:, field: nil)
      @version = version
      @field = field.presence
    end

    def call
      raise(UnsupportedVersionError) unless supported_version?

      { json: reference_data_klass.api_payload(field:), status: :ok }
    end

  private

    attr_reader :version, :field

    def supported_version?
      version >= SUPPORTED_FROM
    end

    def reference_data_klass
      "Hesa::ReferenceData::#{version_module}".constantize
    end

    def version_module
      version.titleize.gsub(/\.|\s/, "")
    end
  end
end
