# frozen_string_literal: true

module Trainees
  class ConfirmPublishCourseController < ApplicationController
    before_action :set_trainee
    before_action :authorize_trainee
    before_action :set_course

    def edit
      @confirm_publish_course_form = ConfirmPublishCourseForm.new(@trainee)
    end

    def update
      @confirm_publish_course_form = ConfirmPublishCourseForm.new(@trainee, course_params)
      if @confirm_publish_course_form.save
        redirect_to review_draft_trainee_path(@trainee)
      else
        render :edit
      end
    end

  private

    def set_trainee
      @trainee = Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(@trainee)
    end

    def set_course
      @course = Course.find_by!(code: params[:id])
    end

    def course_params
      params.fetch(:confirm_publish_course_form, {}).permit(:code)
    end
  end
end
