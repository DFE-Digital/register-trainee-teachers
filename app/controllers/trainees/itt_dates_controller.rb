# frozen_string_literal: true

module Trainees
  class IttDatesController < BaseController
    include Publishable

    before_action :check_if_itt_dates_can_be_taken_from_course

    DATE_CONVERSION = {
      "start_date(3i)" => "start_day",
      "start_date(2i)" => "start_month",
      "start_date(1i)" => "start_year",
      "end_date(3i)" => "end_day",
      "end_date(2i)" => "end_month",
      "end_date(1i)" => "end_year",
    }.freeze

    def edit
      @itt_dates_form = IttDatesForm.new(trainee, params: { course_uuid: })
    end

    def update
      @itt_dates_form = IttDatesForm.new(trainee,
                                         params: itt_dates_params.merge(course_uuid:),
                                         user: current_user)

      if @itt_dates_form.stash_or_save!
        redirect_to(course_confirmation_path)
      else
        render(:edit)
      end
    end

  private

    def itt_dates_params
      params
            .expect(itt_dates_form: [*IttDatesForm::FIELDS, *DATE_CONVERSION])
            .transform_keys { |key| DATE_CONVERSION.fetch(key, key) }
    end

    def course_confirmation_path
      if trainee.apply_application? && trainee.draft?
        trainee_apply_applications_confirm_courses_path(trainee)
      else
        trainee_publish_course_details_confirm_path(trainee)
      end
    end

    def check_if_itt_dates_can_be_taken_from_course
      study_mode = StudyModesForm.new(trainee).study_mode
      course_start_date = course.public_send("#{study_mode}_start_date")
      course_end_date = course.public_send("#{study_mode}_end_date")

      if course_start_date && course_end_date
        IttDatesForm.new(trainee, params: {
          start_day: course_start_date.day,
          start_month: course_start_date.month,
          start_year: course_start_date.year,
          end_day: course_end_date.day,
          end_month: course_end_date.month,
          end_year: course_end_date.year,
          course_uuid: course_uuid,
        }, user: current_user).stash_or_save!

        redirect_to(course_confirmation_path)
      end
    end
  end
end
