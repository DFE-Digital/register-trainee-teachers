# frozen_string_literal: true

class HesaCollectionRequest < ApplicationRecord
  enum state: { import_failed: 0, import_successful: 1 }

  class << self
    def next_from_date
      current_collection_ref = Settings.hesa.current_collection_reference
      latest_request = where(collection_reference: current_collection_ref).import_successful.order(:created_at).last

      return Settings.hesa.current_collection_start_date if latest_request.nil?

      latest_request.requested_at.to_date
    end
  end
end
