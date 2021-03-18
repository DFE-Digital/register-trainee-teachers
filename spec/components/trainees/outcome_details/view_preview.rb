# frozen_string_literal: true

require "govuk/components"

module Trainees
  module OutcomeDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render(OutcomeDetails::View.new(data_model))
      end

    private

      def data_model
        trainee = OpenStruct.new(id: 1, outcome_date: Time.zone.yesterday)
        OpenStruct.new(trainee: trainee, date: trainee.outcome_date)
      end
    end
  end
end
