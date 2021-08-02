# frozen_string_literal: true

module CourseDetails
  class View < GovukComponent::Base
    include SummaryHelper
    include CourseDetailsHelper
    include TraineeHelper

    attr_accessor :data_model

    def initialize(data_model:)
      @data_model = data_model
      @not_provided_copy = t("components.confirmation.not_provided")
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def summary_title
      t("components.course_detail.title")
    end

    def rows
      [
        ({ key: t("components.course_detail.type_of_course"), value: course_type } if require_course_type?),
        ({ key: t("components.course_detail.subject"), value: subject, action: action_link("subject") } if require_subject?),
        ({ key: t("components.course_detail.age_range"), value: course_age_range, action: action_link("age range") } if require_age_range?),
        { key: t("components.course_detail.#{itt_route? ? 'itt' : 'course'}_start_date"), value: course_start_date, action: action_link("course start date") },
        { key: t("components.course_detail.#{itt_route? ? 'itt' : 'course'}_end_date"), value: course_end_date, action: action_link("course end date") },
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
      return t("components.course_detail.details_not_on_publish") if data_model.course_code.blank?

      "#{course.name} (#{course.code})"
    end

    def subject
      return @not_provided_copy if data_model.course_subject_one.blank?

      subjects_for_summary_view(data_model.course_subject_one,
                                data_model.course_subject_two,
                                data_model.course_subject_three)
    end

    def course_age_range
      return @not_provided_copy if data_model.course_age_range.blank?

      age_range_for_summary_view(data_model.course_age_range)
    end

    def course_type
      return @not_provided_copy if trainee.training_route.blank?

      t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}")
    end

    def course_start_date
      return @not_provided_copy if data_model.course_start_date.blank?

      date_for_summary_view(data_model.course_start_date)
    end

    def course_end_date
      return @not_provided_copy if data_model.course_end_date.blank?

      date_for_summary_view(data_model.course_end_date)
    end

    def course
      @course ||= Course.find_by(code: data_model.course_code)
    end
  end
end
