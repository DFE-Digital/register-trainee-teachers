# frozen_string_literal: true

module Trainees
  class PublishCourseDetailsController < ApplicationController
    before_action :authorize_trainee

    def edit
      @courses = @trainee.available_courses
      @publish_course_details = PublishCourseDetailsForm.new(trainee)
    end

    def update
      @publish_course_details = PublishCourseDetailsForm.new(trainee, course_params)

      result = @publish_course_details.stash
      unless result
        @courses = @trainee.available_courses
        render :edit
        return
      end

      if @publish_course_details.manual_entry_chosen?
        redirect_to edit_trainee_course_details_path
      else
        redirect_to edit_trainee_confirm_publish_course_path(id: @publish_course_details.code, trainee_id: @trainee.slug)
      end
    end

  private

    def course_params
      params.fetch(:publish_course_details_form, {}).permit(:code)
    end

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
