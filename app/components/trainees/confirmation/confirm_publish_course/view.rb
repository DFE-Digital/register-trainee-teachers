# frozen_string_literal: true

module Trainees
  module Confirmation
    module ConfirmPublishCourse
      class View < GovukComponent::Base
        include SummaryHelper

        attr_accessor :trainee, :course

        def initialize(trainee:, course:)
          @trainee = trainee
          @course = course
        end

        def heading
          t(".heading")
        end

        def summary_title
          t(".summary_title")
        end

        def rows
          [
            {
              key: t(".summary_title"),
              value: course_details,
              action: govuk_link_to(t(".change_course"), edit_trainee_publish_course_details_path(@trainee)),
            },
            {
              key: t(".subject"),
              value: subject,
            },
            {
              key: t(".level"),
              value: level,
            },
            {
              key: t(".age_range"),
              value: age_range,
            },
            {
              key: t(".start_date"),
              value: start_date,
            },
            {
              key: t(".duration"),
              value: duration,
            },
          ]
        end

        def course_details
          "#{course.name} (#{course.code})"
        end

        def subject
          course.name
        end

        def level
          course.level&.capitalize
        end

        delegate :age_range, to: :course

        def start_date
          date_for_summary_view(course.start_date)
        end

        def duration
          pluralize(course.duration_in_years, "year")
        end
      end
    end
  end
end
