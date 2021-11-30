# frozen_string_literal: true

module Dttp
  class PlacementAssignment < ApplicationRecord
    self.table_name = "dttp_placement_assignments"

    validates :response, presence: true

    enum state: {
      unprocessed: 0,
    }
  end
end
