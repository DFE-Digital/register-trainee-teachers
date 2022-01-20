# frozen_string_literal: true

module Dttp
  class DormantPeriod < ApplicationRecord
    self.table_name = "dttp_dormant_periods"

    belongs_to :placement_assignment, foreign_key: :placement_assignment_dttp_id, primary_key: :dttp_id, inverse_of: :dormant_period, optional: true

    validates :response, presence: true
  end
end
