# frozen_string_literal: true

require "govuk/components"

module Trainees
  module OutcomeDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render_component(OutcomeDetails::View.new(mock_trainee))
      end

    private

      def mock_trainee
        OpenStruct.new(outcome_date: Time.zone.yesterday)
      end
    end
  end
end
