# frozen_string_literal: true

require "govuk/components"

module Confirmation
  module CourseDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render(View.new(data_model: mock_trainee))
      end

      def with_no_data
        render(View.new(data_model: Trainee.new(id: 2, training_route: TRAINING_ROUTE_ENUMS[:assessment_only])))
      end

      def with_multiple_subjects
        render(View.new(data_model: mock_trainee_with_multiple_subjects))
      end

    private

      def mock_trainee
        @mock_trainee ||= Trainee.new(
          id: 1,
          course_subject_one: "Primary",
          course_age_range: [3, 11],
          course_start_date: Date.new(2020, 1, 28),
          training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
        )
      end

      def mock_trainee_with_multiple_subjects
        Trainee.new(
          id: 1,
          course_subject_one: "Primary",
          course_subject_two: "Science",
          course_age_range: [3, 11],
          course_start_date: Date.new(2020, 1, 28),
          training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
        )
      end
    end
  end
end
