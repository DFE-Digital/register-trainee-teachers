# frozen_string_literal: true

module Api
  class ReferenceDataResponse < BaseService
    class UnsupportedVersionError < StandardError; end

    def initialize(version:, field: nil)
      @version = version
      @field = field.presence
    end

    def call
      raise(UnsupportedVersionError) unless reference_data_klass.respond_to?(:api_payload)

      { json: reference_data_klass.api_payload(field:), status: :ok }
    end

  private

    attr_reader :version, :field

    def reference_data_klass
      "Hesa::ReferenceData::#{Api::GetVersionedItem.module_name(version)}".constantize
    end
  end
end
