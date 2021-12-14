# frozen_string_literal: true

module Trainees
  class StudyModesController < BaseController
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

    def check_if_study_mode_can_be_taken_from_course
      if course.single_study_mode?
        StudyModesForm.new(trainee, params: { study_mode: course.study_mode }, user: current_user).stash_or_save!
        redirect_to(edit_trainee_course_details_itt_dates_path(trainee))
      end
    end
  end
end
