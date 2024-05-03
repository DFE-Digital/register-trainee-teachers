module Sourceable
  extend ActiveSupport::Concern

  APPLY_SOURCE = "apply".freeze
  DTTP_SOURCE = "dttp".freeze
  HESA_COLLECTION_SOURCE = "hesa_collection".freeze
  HESA_TRN_DATA_SOURCE = "hesa_trn_data".freeze
  MANUAL_SOURCE = "manual".freeze
  API_SOURCE = "api".freeze
  ALL = [
    APPLY_SOURCE,
    DTTP_SOURCE,
    HESA_COLLECTION_SOURCE,
    HESA_TRN_DATA_SOURCE,
    MANUAL_SOURCE,
    API_SOURCE
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
