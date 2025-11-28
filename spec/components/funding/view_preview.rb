# frozen_string_literal: true

require "govuk/components"

module Funding
  class ViewPreview < ViewComponent::Preview
    def default
      render(Funding::View.new(data_model: mock_trainee))
    end

  private

    def mock_trainee
      @mock_trainee ||= Trainee.new(
        id: 1,
        course_subject_one: "Primary",
        course_age_range: [3, 11],
        itt_start_date: Date.new(2020, 0o1, 28),
        training_route: ReferenceData::TRAINING_ROUTES.assessment_only.name,
        training_initiative: ROUTE_INITIATIVES.keys.first,
      )
    end
  end
end
