# frozen_string_literal: true

module ConfirmPublishCourse
  class View < ViewComponent::Base
    include SummaryHelper
    include CourseDetailsHelper

    attr_accessor :trainee, :course, :specialisms, :itt_start_date, :course_study_mode

    def initialize(trainee:, course:, specialisms:, itt_start_date:, course_study_mode:)
      @trainee = trainee
      @course = course
      @specialisms = specialisms
      @itt_start_date = itt_start_date
      @course_study_mode = course_study_mode
    end

    def heading
      t(".heading")
    end

    def heading_text
      t(".heading_text")
    end

    def summary_title
      t(".summary_title")
    end

    def summary_rows
      [
        {
          key: t(".summary_title"),
          value: course_details,
          action: edit_trainee_publish_course_details_path(@trainee),
        },
        { key: subject_key, value: subject_names },
        { key: t(".level"), value: level },
        { key: t(".age_range"), value: age_range },
        { key: t(".itt_start_date"), value: start_date },
        { key: t(".duration"), value: duration },
        ({ key: t(".study_mode"), value: study_mode } if requires_study_mode?),
      ].compact
    end

    def course_details
      "#{course.name} (#{course.code})"
    end

    def subject_names
      specialism1, specialism2, specialism3 = *specialisms.map { |s| format_language(s) }
      subjects_for_summary_view(
        specialism1,
        specialism2,
        specialism3,
      )
    end

    def level
      course.level&.capitalize
    end

    def age_range
      age_range_for_summary_view(course.age_range)
    end

    def start_date
      date_for_summary_view(itt_start_date || course.start_date)
    end

    def duration
      pluralize(course.duration_in_years, "year")
    end

    def study_mode
      (course_study_mode || course.study_mode).humanize
    end

  private

    def subject_key
      course.subjects.many? ? t(".multiple_subjects") : t(".subject")
    end

    delegate :requires_study_mode?, to: :trainee
  end
end
