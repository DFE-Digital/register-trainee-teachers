# frozen_string_literal: true

require "govuk/components"

module Trainees
  module Confirmation
    module ConfirmPublishCourse
      class ViewPreview < ViewComponent::Preview
        def default
          render(Trainees::Confirmation::ConfirmPublishCourse::View.new(trainee: mock_trainee, course: mock_course))
        end

        def with_no_data
          trainee = Trainee.new(id: 2, training_route: TRAINING_ROUTE_ENUMS[:assessment_only])
          render(Trainees::Confirmation::ConfirmPublishCourse::View.new(trainee: trainee, course: mock_course))
        end

      private

        def mock_trainee
          @mock_trainee ||= Trainee.new(
            id: 1,
            subject: "Primary",
            course_age_range: [3, 11],
            course_start_date: Date.new(2020, 0o1, 28),
            training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
          )
        end

        def mock_course
          @mock_course ||= FactoryBot.build(:course)
        end
      end
    end
  end
end
