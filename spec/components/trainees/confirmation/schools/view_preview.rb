# frozen_string_literal: true

require "govuk/components"
module Trainees
  module Confirmation
    module Schools
      class ViewPreview < ViewComponent::Preview
        def default
          render(Trainees::Confirmation::Schools::View.new(data_model: mock_trainee))
        end

        def with_no_data
          render(Trainees::Confirmation::Schools::View.new(data_model: Trainee.new(id: 2, training_route: TRAINING_ROUTE_ENUMS[:assessment_only], lead_school: mock_school)))
        end

      private

        def mock_trainee
          @mock_trainee ||= Trainee.new(
            id: 1,
            subject: "Primary",
            course_age_range: [3, 11],
            course_start_date: Date.new(2020, 0o1, 28),
            training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
            lead_school: mock_school,
          )
        end

        def mock_school
          @mock_school ||= School.new(
            id: 1,
            urn: "12345",
            name: "Test School",
            postcode: "E1 5DJ",
            town: "London",
            open_date: Time.zone.today,
          )
        end
      end
    end
  end
end
