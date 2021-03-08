# frozen_string_literal: true

require "govuk/components"
module Trainees
  module Confirmation
    module ProgrammeDetails
      class ViewPreview < ViewComponent::Preview
        def default
          render(Trainees::Confirmation::ProgrammeDetails::View.new(trainee: mock_trainee))
        end

        def with_no_data
          render(Trainees::Confirmation::ProgrammeDetails::View.new(trainee: Trainee.new(id: 2, training_route: TRAINING_ROUTE_ENUMS[:assessment_only])))
        end

      private

        def mock_trainee
          @mock_trainee ||= Trainee.new(
            id: 1,
            subject: "Primary",
            age_range: "3 to 11 programme",
            programme_start_date: Date.new(2020, 0o1, 28),
            training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
          )
        end
      end
    end
  end
end
