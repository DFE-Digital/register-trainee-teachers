# frozen_string_literal: true

module Trainees
  class StudyModesController < BaseController
    include PublishCourseNextPath

    def edit
      @study_mode_form = StudyModesForm.new(trainee)
    end

    def update
      @study_mode_form = StudyModesForm.new(trainee, params: trainee_params, user: current_user)
      if @study_mode_form.stash_or_save!
        redirect_to(course_confirmation_path)
      else
        render(:edit)
      end
    end

  private

    def trainee_params
      params.fetch(:study_modes_form, {}).permit(:study_mode)
    end
  end
end
