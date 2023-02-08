# frozen_string_literal: true

module Trainees
  class PublishCourseDetailsController < BaseController
    include Publishable

    before_action :redirect_to_course_years_page, only: :edit

    before_action :set_course_year

    helper_method :training_route

    def edit
      @courses = course_year_available_courses
      @publish_course_details_form = PublishCourseDetailsForm.new(trainee)

      if @courses.blank?
        page_tracker.remove_last_page
        if year.present?
          @publish_course_details_form.process_manual_entry!
          redirect_to(edit_trainee_course_education_phase_path(trainee))
        else
          redirect_to(edit_trainee_course_years_path(trainee))
        end
      end
    end

    def update
      @publish_course_details_form = PublishCourseDetailsForm.new(trainee, params: course_params, user: current_user)

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
      course_years_form = CourseYearsForm.new(trainee: trainee, params: { course_year: year })
      if course_years_form.valid?
        @course_year = course_years_form.course_year
      else
        redirect_to_course_years_page
      end
    end

    def year
      @year ||= params[:year].presence ||
        trainee.published_course&.recruitment_cycle_year ||
        trainee.start_academic_cycle&.start_year ||
        Settings.current_default_course_year
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
      trainee.available_courses(training_route)&.where(recruitment_cycle_year: @course_year)
    end

    def course_params
      params.fetch(:publish_course_details_form, {}).permit(:course_uuid)
    end

    def redirect_to_course_years_page
      return unless FeatureService.show_draft_trainee_course_year_choice?(trainee)
      return if params[:year].present?

      page_tracker.remove_last_page
      redirect_to(edit_trainee_course_years_path(trainee))
    end
  end
end
