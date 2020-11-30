# frozen_string_literal: true

require "govuk/components"

module Trainees
  module RecordDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render_component(Trainees::RecordDetails::View.new(mock_trainee("ABC-1234-XYZ")))
      end

      def with_no_trainee_id
        render_component(Trainees::RecordDetails::View.new(mock_trainee(nil)))
      end

    private

      def mock_trainee(trainee_id)
        @mock_trainee ||= Trainee.new(
          id: 1,
          record_type: :assessment_only,
          trainee_id: trainee_id,
          created_at: Time.zone.today,
          updated_at: Time.zone.today,
        )
      end
    end
  end
end
