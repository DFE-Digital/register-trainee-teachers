# frozen_string_literal: true

module CourseDetails
  class View < GovukComponent::Base
    include SummaryHelper
    include CourseDetailsHelper
    include TraineeHelper

    def initialize(data_model:, has_errors: false)
      @data_model = data_model
      @trainee = data_model.is_a?(Trainee) ? data_model : data_model.trainee
      @has_errors = has_errors
      @not_provided_copy = t("components.confirmation.not_provided")
    end

    def summary_title
      t("components.course_detail.title")
    end

    def rows
      [
        type_of_course,
        subject_row,
        age_range_row,
        study_mode_row,
        course_date_row(course_start_date, :start),
        course_date_row(course_end_date, :end),
      ].compact.tap do |collection|
        if show_publish_courses?(trainee)
          collection.unshift({
            key: t("components.course_detail.course_details"),
            value: course_details,
            action: action_link("course details", path: edit_trainee_publish_course_details_path(trainee)),
          })
        end
      end
    end

  private

    attr_accessor :data_model, :trainee, :has_errors

    def type_of_course
      if require_course_type?
        { key: t("components.course_detail.type_of_course"), value: course_type }
      end
    end

    def subject_row
      if require_subject?
        mappable_field(subject_names, t("components.course_detail.subject"))
      end
    end

    def age_range_row
      if require_age_range?
        mappable_field(course_age_range, t("components.course_detail.age_range"))
      end
    end

    def study_mode_row
      if trainee.requires_study_mode?
        mappable_field(study_mode, t("components.course_detail.study_mode"))
      end
    end

    def course_date_row(value, context)
      mappable_field(value, t("components.course_detail.#{itt_route? ? 'itt' : 'course'}_#{context}_date"))
    end

    def itt_route?
      trainee.itt_route?
    end

    def require_subject?
      !trainee.early_years_route?
    end

    def require_age_range?
      !trainee.early_years_route?
    end

    def require_course_type?
      return true unless trainee.early_years_route?

      !trainee.draft?
    end

    def action_link(text, path: edit_trainee_course_details_path(trainee))
      govuk_link_to("#{t(:change)}<span class='govuk-visually-hidden'> #{text}</span>".html_safe, path)
    end

    def course_details
      return t("components.course_detail.details_not_on_publish") if trainee.course_code.blank?

      "#{course.name} (#{course.code})"
    end

    def subject_names
      if trainee.course_subject_one.present?
        return subjects_for_summary_view(trainee.course_subject_one,
                                         trainee.course_subject_two,
                                         trainee.course_subject_three)
      end

      return apply_subject_names if trainee.apply_application?
    end

    def course_age_range
      return age_range_for_summary_view(trainee.course_age_range) if trainee.course_age_range.present?

      return age_range_for_summary_view(course.age_range) if trainee.apply_application?
    end

    def study_mode
      t("components.course_detail.study_mode_values.#{trainee.study_mode}") if trainee.study_mode.present?
    end

    def course_type
      return @not_provided_copy if trainee.training_route.blank?

      t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}")
    end

    def course_start_date
      return date_for_summary_view(trainee.course_start_date) if trainee.course_start_date.present?

      apply_trainee_course_start_date if trainee.apply_application?
    end

    def course_end_date
      return date_for_summary_view(trainee.course_end_date) if trainee.course_end_date.present?

      apply_trainee_course_end_date if trainee.apply_application?
    end

    def course
      @course ||= trainee.available_courses.find_by(code: trainee.course_code)
    end

    def mappable_field(field_value, field_label)
      MappableFieldRow.new(
        field_value: field_value,
        field_label: field_label,
        text: t("components.confirmation.missing"),
        action_url: edit_trainee_course_details_path(trainee),
        has_errors: has_errors,
      ).to_h
    end

    def apply_subject_names
      specialism1, specialism2, specialism3 = *data_model.specialisms
      subjects_for_summary_view(
        specialism1,
        specialism2,
        specialism3,
      )
    end

    def apply_trainee_course_start_date
      date_for_summary_view(data_model.itt_start_date || course.start_date)
    end

    def apply_trainee_course_end_date
      date_for_summary_view(course.end_date)
    end
  end
end
