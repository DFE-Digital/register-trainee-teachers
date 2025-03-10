# frozen_string_literal: true

# == Schema Information
#
# Table name: hesa_collection_requests
#
#  id                   :bigint           not null, primary key
#  collection_reference :string
#  requested_at         :datetime
#  response_body        :text
#  state                :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_hesa_collection_requests_on_state  (state)
#
module Hesa
  class CollectionRequest < ApplicationRecord
    self.table_name = "hesa_collection_requests"

    enum :state, { import_failed: 0, import_successful: 1 }

    class << self
      def next_from_date
        current_collection_ref = Settings.hesa.current_collection_reference
        latest_request = where(collection_reference: current_collection_ref).import_successful.order(:created_at).last

        return Settings.hesa.current_collection_start_date if latest_request.nil?

        latest_request.requested_at.to_date
      end
    end
  end
end
