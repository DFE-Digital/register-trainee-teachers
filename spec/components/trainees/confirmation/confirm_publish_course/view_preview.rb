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
          render(Trainees::Confirmation::ConfirmPublishCourse::View.new(trainee: Trainee.new(id: 2, training_route: TRAINING_ROUTE_ENUMS[:assessment_only]), course: mock_course))
        end

      private

        def mock_trainee
          @mock_trainee ||= Trainee.new(
            id: 1,
            subject: "Primary",
            age_range: "3 to 11 course",
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
