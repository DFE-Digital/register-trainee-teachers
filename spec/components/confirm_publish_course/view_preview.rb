# frozen_string_literal: true

require "govuk/components"

module ConfirmPublishCourse
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(trainee: mock_trainee, course: build_course))
    end

    def with_multiple_subjects
      course = build_course
      course.subjects << Subject.new(name: "Subject two")
      render(View.new(trainee: mock_trainee, course: course))
    end

  private

    def mock_trainee
      @mock_trainee ||= Trainee.new(
        id: 1,
        course_subject_one: "Primary",
        course_age_range: [3, 11],
        course_start_date: Date.new(2020, 0o1, 28),
        training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
      )
    end

    def build_course
      Course.new(
        id: 1,
        name: "Primary",
        code: "2CX",
        level: :primary,
        min_age: 7,
        max_age: 11,
        start_date: Time.zone.today,
        duration_in_years: 1,
        subjects: [Subject.new(name: "Subject 1")],
      )
    end
  end
end
