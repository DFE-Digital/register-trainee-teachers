# frozen_string_literal: true

module Trainees
  class StudyModesController < ApplicationController
    include PublishCourseNextPath

    before_action :authorize_trainee

    def edit
      @study_mode_form = StudyModesForm.new(trainee, params: { study_mode: nil })
    end

    def update
      @study_mode_form = StudyModesForm.new(trainee, params: trainee_params, user: current_user)
      if @study_mode_form.stash
        redirect_to course_confirmation_path
      else
        render :edit
      end
    end

  private

    def trainee_params
      params.fetch(:study_modes_form, {}).permit(:study_mode)
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
