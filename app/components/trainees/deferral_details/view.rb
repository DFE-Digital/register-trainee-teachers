# frozen_string_literal: true

module Trainees
  module DeferralDetails
    class View < GovukComponent::Base
      include SummaryHelper

      attr_reader :data_model

      def initialize(data_model)
        @data_model = data_model
      end

      def defer_date
        date_for_summary_view(data_model.date)
      end
    end
  end
end
