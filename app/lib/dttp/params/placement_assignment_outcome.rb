# frozen_string_literal: true

module Dttp
  module Params
    class PlacementAssignmentOutcome
      STANDARDS_PASSED = "bcdd9255-0fc2-e611-80be-00155d010316"
      SUCCESSFUL_COMPLETION_OF_COURSE = "3f6a46ad-11c2-e611-80be-00155d010316"

      delegate :to_json, to: :params

      def initialize(trainee:)
        @trainee = trainee
      end

      def params
        @params ||= {
          "dfe_dateleft" => date_left,
          "dfe_datestandardsassessmentpassed" => date_left,
          "dfe_StandardAssessedId@odata.bind" => "/dfe_standardassesseds(#{STANDARDS_PASSED})",
          "dfe_ReasonforLeavingId@odata.bind" => "/dfe_reasonforleavings(#{SUCCESSFUL_COMPLETION_OF_COURSE})",
          "dfe_recommendtraineetonctl" => true,
        }
      end

    private

      attr_reader :trainee

      def date_left
        # TODO: this will be different for non-assessment only routes
        # we don't currently collect a leaving date for assessment only
        date_standards_assessed
      end

      def date_standards_assessed
        trainee.outcome_date ? trainee.outcome_date.in_time_zone.iso8601 : nil
      end
    end
  end
end
