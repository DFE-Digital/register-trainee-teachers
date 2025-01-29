# frozen_string_literal: true

module Sourceable
  extend ActiveSupport::Concern

  APPLY_SOURCE = "apply"
  DTTP_SOURCE = "dttp"
  HESA_COLLECTION_SOURCE = "hesa_collection"
  HESA_TRN_DATA_SOURCE = "hesa_trn_data"
  MANUAL_SOURCE = "manual"
  API_SOURCE = "api"
  CSV_SOURCE = "csv"
  ALL = [
    APPLY_SOURCE,
    DTTP_SOURCE,
    HESA_COLLECTION_SOURCE,
    HESA_TRN_DATA_SOURCE,
    MANUAL_SOURCE,
    API_SOURCE,
    CSV_SOURCE,
  ].freeze
  NON_TRN_SOURCES = ALL - [HESA_TRN_DATA_SOURCE].freeze
  HESA_SOURCES = [HESA_COLLECTION_SOURCE, HESA_TRN_DATA_SOURCE].freeze

  included do
    enum :record_source, ALL.to_h { |r| [r, r] }, suffix: :record, instance_methods: true

    after_initialize :set_manual_record_source, if: -> { record_source.nil? }

    def hesa_record?
      hesa_collection_record? || hesa_trn_data_record?
    end

  private

    def set_manual_record_source
      self.record_source = MANUAL_SOURCE
    end
  end
end
