# frozen_string_literal: true

module Sourceable
  extend ActiveSupport::Concern

  APPLY_SOURCE = "apply"
  DTTP_SOURCE = "dttp"
  HESA_COLLECTION_SOURCE = "hesa_collection"
  HESA_TRN_DATA_SOURCE = "hesa_trn_data"
  MANUAL_SOURCE = "manual"
  API_SOURCE = "api"
  ALL = [
    APPLY_SOURCE,
    DTTP_SOURCE,
    HESA_COLLECTION_SOURCE,
    HESA_TRN_DATA_SOURCE,
    MANUAL_SOURCE,
    API_SOURCE,
  ].freeze
  NON_TRN_SOURCES = ALL - [HESA_TRN_DATA_SOURCE].freeze

  included do
    enum record_source: {
      apply: APPLY_SOURCE,
      dttp: DTTP_SOURCE,
      hesa_collection: HESA_COLLECTION_SOURCE,
      hesa_trn_data: HESA_TRN_DATA_SOURCE,
      manual: MANUAL_SOURCE,
      api: API_SOURCE,
    }, _suffix: :record
  end
end
