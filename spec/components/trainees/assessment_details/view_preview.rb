# frozen_string_literal: true

require "govuk/components"

module Trainees
  module AssessmentDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render_component(Trainees::AssessmentDetails::View.new(mock_trainee))
      end

    private

      def mock_trainee
        OpenStruct.new(
          assessment_outcome: "passed",
          assessment_end_date: Time.zone.yesterday,
        )
      end
    end
  end
end
