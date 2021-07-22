# frozen_string_literal: true

require "govuk/components"

module InvalidDataText
  class ViewPreview < ViewComponent::Preview
    def default
      render InvalidDataText::View.new(trainee: trainee, form_section: :institution, hint: "I am a very good hint!")
    end

  private

    def trainee
      @trainee ||= Trainee.new(
        id: 1,
        course_subject_one: "Primary",
        course_age_range: [3, 11],
        course_start_date: Date.new(2020, 0o1, 28),
        training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
        training_initiative: ROUTE_INITIATIVES.keys.first,
        apply_application_id: 1,
      )
    end
  end
end
