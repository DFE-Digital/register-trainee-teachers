# frozen_string_literal: true

module Trainees
  class StudyModesController < BaseController
    include CoursePrerequisitesCheckable

    include Publishable

    before_action :check_if_study_mode_can_be_taken_from_course

    def edit
      @study_mode_form = StudyModesForm.new(trainee)
    end

    def update
      @study_mode_form = StudyModesForm.new(trainee, params: trainee_params, user: current_user)

      if @study_mode_form.stash_or_save!
        redirect_to(edit_trainee_course_details_itt_dates_path(trainee))
      else
        render(:edit)
      end
    end

  private

    def trainee_params
      params.fetch(:study_modes_form, {}).permit(:study_mode)
    end

    # The early years teacher degree apprenticeship is full time only, so there's no choice to make.
    def check_if_study_mode_can_be_taken_from_course
      if trainee.requires_level_five_declaration?
        StudyModesForm.new(trainee, params: { study_mode: COURSE_STUDY_MODES[:full_time] }, user: current_user).stash_or_save!
        redirect_to(edit_trainee_course_details_itt_dates_path(trainee))
      elsif course.single_study_mode?
        StudyModesForm.new(trainee, params: { study_mode: course.study_mode }, user: current_user).stash_or_save!
        redirect_to(edit_trainee_course_details_itt_dates_path(trainee))
      end
    end
  end
end
