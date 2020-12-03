# frozen_string_literal: true

module Trainees
  module OutcomeDetails
    class View < GovukComponent::Base
      include SummaryHelper

      attr_reader :trainee

      def initialize(trainee)
        @trainee = trainee
      end

      def outcome_date
        date_for_summary_view(trainee.outcome_date)
      end
    end
  end
end
