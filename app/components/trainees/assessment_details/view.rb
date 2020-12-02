# frozen_string_literal: true

module Trainees
  module AssessmentDetails
    class View < GovukComponent::Base
      include SummaryHelper

      attr_reader :trainee

      def initialize(trainee)
        @trainee = trainee
      end

      def assessment_outcome
        trainee.assessment_outcome.humanize
      end

      def assessment_end_date
        date_for_summary_view(trainee.assessment_end_date)
      end
    end
  end
end
