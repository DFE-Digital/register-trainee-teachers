# frozen_string_literal: true

module Dttp
  module Params
    class Dormancy
      delegate :to_json, to: :params

      def initialize(trainee:)
        @trainee = trainee
      end

      def params
        @params ||= {
          "dfe_dateleftcourse" => date_left,
          "dfe_datereturnedtocourse" => date_returned,
          "dfe_TrainingRecordId@odata.bind" => "/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})",
        }
      end

    private

      attr_reader :trainee

      def date_left
        trainee.defer_date.in_time_zone.iso8601
      end

      def date_returned
        trainee.reinstate_date ? trainee.reinstate_date.in_time_zone.iso8601 : nil
      end
    end
  end
end
