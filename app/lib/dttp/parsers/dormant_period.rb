# frozen_string_literal: true

module Dttp
  module Parsers
    class DormantPeriod
      class << self
        def to_attributes(dormant_periods:)
          dormant_periods.map do |dormant_period|
            {
              dttp_id: dormant_period["dfe_dormantperiodid"],
              placement_assignment_dttp_id: dormant_period["_dfe_trainingrecordid_value"],
              response: dormant_period,
            }
          end
        end
      end
    end
  end
end
