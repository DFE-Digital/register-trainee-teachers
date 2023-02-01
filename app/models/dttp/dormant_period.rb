# frozen_string_literal: true

# == Schema Information
#
# Table name: dttp_dormant_periods
#
#  id                           :bigint           not null, primary key
#  response                     :jsonb
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  dttp_id                      :uuid             not null
#  placement_assignment_dttp_id :uuid
#
# Indexes
#
#  index_dttp_dormant_periods_on_dttp_id  (dttp_id) UNIQUE
#
module Dttp
  class DormantPeriod < ApplicationRecord
    self.table_name = "dttp_dormant_periods"

    belongs_to :placement_assignment, foreign_key: :placement_assignment_dttp_id, primary_key: :dttp_id, inverse_of: :dormant_period, optional: true

    validates :response, presence: true

    def date_left
      response["dfe_dateleftcourse"]
    end

    def date_returned
      response["dfe_datereturnedtocourse"]
    end
  end
end
