# frozen_string_literal: true

module Trainees
  module DeferralDetails
    class View < GovukComponent::Base
      include SummaryHelper

      attr_reader :trainee

      def initialize(trainee)
        @trainee = trainee
      end

      def defer_date
        date_for_summary_view(trainee.defer_date)
      end
    end
  end
end
