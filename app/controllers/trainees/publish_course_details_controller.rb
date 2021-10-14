# frozen_string_literal: true

module Trainees
  class PublishCourseDetailsController < BaseController
    include PublishCourseNextPath

    def edit
      @courses = trainee.available_courses
      @publish_course_details_form = PublishCourseDetailsForm.new(trainee)
    end

    def update
      @publish_course_details_form = PublishCourseDetailsForm.new(trainee, params: course_params, user: current_user)
      @publish_course_details_form.skip_course_end_date_validation!

      if @publish_course_details_form.stash_or_save!
        if @publish_course_details_form.manual_entry_chosen?
          @publish_course_details_form.process_manual_entry!
        end

        redirect_to(next_step_path)
      else
        @courses = trainee.available_courses
        render(:edit)
      end
    end

  private

    def course_code
      @publish_course_details_form.course_code
    end

    def next_step_path
      if @publish_course_details_form.manual_entry_chosen?
        edit_trainee_course_education_phase_path(trainee)
      elsif @publish_course_details_form.language_specialism?
        edit_trainee_language_specialisms_path(trainee)
      else
        edit_trainee_subject_specialism_path(trainee, 1)
      end
    end

    def course_params
      params.fetch(:publish_course_details_form, {}).permit(:course_uuid)
    end
  end
end
