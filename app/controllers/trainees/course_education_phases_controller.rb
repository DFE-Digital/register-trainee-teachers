# frozen_string_literal: true

module Trainees
  class CourseEducationPhasesController < ApplicationController
    before_action :authorize_trainee

    def edit
      @course_education_phase_form = ::CourseEducationPhaseForm.new(trainee)
    end

    def update
      @course_education_phase_form = ::CourseEducationPhaseForm.new(trainee, params: course_params, user: current_user)

      if @course_education_phase_form.stash_or_save!
        redirect_to(edit_trainee_course_details_path)
      else
        render(:edit)
      end
    end

  private

    def course_params
      params.require(:course_education_phase_form).permit(*::CourseEducationPhaseForm::FIELDS)
    end

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
