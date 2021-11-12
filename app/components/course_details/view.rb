# frozen_string_literal: true

module CourseDetails
  class View < GovukComponent::Base
    include SummaryHelper
    include CourseDetailsHelper
    include TraineeHelper

    def initialize(data_model:, has_errors: false, system_admin: false)
      @data_model = data_model
      @trainee = data_model.is_a?(Trainee) ? data_model : data_model.trainee
      @has_errors = has_errors
      @system_admin = system_admin
    end

    def summary_title
      t("components.course_detail.title")
    end

    def rows
      [
        training_route_row,
        publish_course_details_row,
        education_phase_row,
        subject_row,
        age_range_row,
        study_mode_row,
        course_date_row(course_start_date, :start),
        course_date_row(course_end_date, :end),
      ].compact
    end

  private

    attr_accessor :data_model, :trainee, :has_errors, :system_admin

    def publish_course_details_row
      if show_publish_courses?(trainee)
        { key: t("components.course_detail.course_details"),
          value: course_details,
          action_href: edit_trainee_publish_course_details_path(trainee),
          action_text: t(:change),
          action_visually_hidden_text: "course details",
          custom_value: true }
      end
    end

    def education_phase_row
      if non_early_year_route?
        { field_value: data_model.course_education_phase&.upcase_first, field_label: t("components.course_detail.education_phase"), action_url: edit_trainee_course_education_phase_path(trainee) }
      end
    end

    def subject_row
      if non_early_year_route?
        default_mappable_field(subject_names, t("components.course_detail.subject"))
      end
    end

    def training_route_row
      unless trainee.draft?
        { field_value: t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"), field_label: t("components.course_detail.route"), action_url: nil }
      end
    end

    def age_range_row
      if non_early_year_route?
        default_mappable_field(course_age_range, t("components.course_detail.age_range"))
      end
    end

    def study_mode_row
      if trainee.requires_study_mode?
        default_mappable_field(study_mode, t("components.course_detail.study_mode"))
      end
    end

    def course_date_row(value, context)
      default_mappable_field(value, t("components.course_detail.itt_#{context}_date"))
    end

    def non_early_year_route?
      !trainee.early_years_route?
    end

    def course_details
      return t("components.course_detail.details_not_on_publish") if data_model.course_uuid.blank?

      "#{course.name} (#{course.code})" if course
    end

    def subject_names
      if data_model.course_subject_one.present?
        subjects_for_summary_view(
          *[
            data_model.course_subject_one,
            data_model.course_subject_two,
            data_model.course_subject_three,
          ].map { |s| format_language(s) },
        )
      end
    end

    def course_age_range
      if data_model.course_age_range.present?
        age_range_for_summary_view(data_model.course_age_range)
      end
    end

    def study_mode
      t("components.course_detail.study_mode_values.#{data_model.study_mode}") if data_model.study_mode.present?
    end

    def course_start_date
      if data_model.course_start_date.present?
        date_for_summary_view(data_model.course_start_date)
      end
    end

    def course_end_date
      if data_model.course_end_date.present?
        date_for_summary_view(data_model.course_end_date)
      end
    end

    def course
      @course ||= trainee.available_courses.find_by(uuid: data_model.course_uuid)
    end

    def default_mappable_field(field_value, field_label)
      { field_value: field_value, field_label: field_label, action_url: edit_trainee_course_details_path(trainee) }
    end
  end
end
