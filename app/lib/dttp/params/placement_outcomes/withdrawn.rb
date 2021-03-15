# frozen_string_literal: true

module Dttp
  module Params
    module PlacementOutcomes
      class Withdrawn
        include Mappable
        NO_QUALIFICATION_OBTAINED_ON_EXIT = "eaee7457-9448-e811-80f2-005056ac45bb"

        delegate :to_json, to: :params

        def initialize(trainee:)
          @trainee = trainee
        end

        def params
          @params ||= {
            "dfe_dateleft" => date_left,
            "dfe_datestandardsassessmentpassed" => date_standards_assessed,
            "dfe_ReasonforLeavingId@odata.bind" => "/dfe_reasonforleavings(#{dttp_reason_for_leaving_id(trainee.withdraw_reason)})",
            "dfe_ITTQualificationAimId@odata.bind" => "/dfe_ittqualificationaims(#{NO_QUALIFICATION_OBTAINED_ON_EXIT})",
          }
        end

      private

        attr_reader :trainee

        def date_left
          trainee.withdraw_date.in_time_zone.iso8601
        end

        def date_standards_assessed
          trainee.outcome_date ? trainee.outcome_date.in_time_zone.iso8601 : nil
        end
      end
    end
  end
end
