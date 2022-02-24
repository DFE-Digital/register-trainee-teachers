# frozen_string_literal: true

class HesaCollectionRequest < ApplicationRecord

  enum state: {
    importable: 0,
    imported: 1,
    non_importable_missing_route: 2,
    non_importable_provider: 3,
    non_importable_missing_funding: 4,
    non_importable_missing_initiative: 5,
  }

  class << self
    def next_from_date
      current_collection_ref = Settings.hesa.current_collection_reference
      latest_request = where(collection_reference: current_collection_ref).order(:created_at).last

      return DateTime.parse(Settings.hesa.current_collection_start_date).utc.iso8601 if latest_request.nil?

      latest_request.requested_at.utc.iso8601
    end
  end
end
