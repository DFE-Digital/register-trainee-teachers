# frozen_string_literal: true

module Dttp
  module Params
    module PlacementOutcomes
      class Withdrawn
        include Mappable

        delegate :to_json, to: :params

        def initialize(trainee:)
          @trainee = trainee
        end

        def params
          @params ||= {
            "dfe_dateleft" => date_left,
            "dfe_ReasonforLeavingId@odata.bind" => "/dfe_reasonforleavings(#{dttp_reason_for_leaving_id(trainee.withdraw_reason)})",
          }
        end

      private

        attr_reader :trainee

        def date_left
          trainee.withdraw_date.in_time_zone.iso8601
        end
      end
    end
  end
end
