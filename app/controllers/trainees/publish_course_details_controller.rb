# frozen_string_literal: true

module Trainees
  class PublishCourseDetailsController < BaseController
    include PublishCourseNextPath

    before_action :set_course_year

    def edit
      @courses = course_year_available_courses
      @publish_course_details_form = PublishCourseDetailsForm.new(trainee)
      @publish_course_details_form.skip_course_end_date_validation!

      if @courses.empty?
        page_tracker.remove_last_page
        if params[:year].present?
          @publish_course_details_form.process_manual_entry!
          redirect_to(edit_trainee_course_education_phase_path(trainee))
        else
          redirect_to(edit_trainee_course_years_path(trainee))
        end
      end
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
        @courses = course_year_available_courses
        render(:edit)
      end
    end

  private

    def set_course_year
      year = params[:year].presence
      year ||= @trainee.published_course&.recruitment_cycle_year
      year ||= Settings.current_default_course_year

      course_years_form = CourseYearsForm.new(course_year: year)
      if course_years_form.valid?
        @course_year = course_years_form.course_year
      else
        redirect_to(edit_trainee_course_years_path(@trainee))
      end
    end

    def course_uuid
      @publish_course_details_form.course_uuid
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

    def course_year_available_courses
      trainee.available_courses.where(recruitment_cycle_year: @course_year)
    end

    def course_params
      params.fetch(:publish_course_details_form, {}).permit(:course_uuid)
    end
  end
end
