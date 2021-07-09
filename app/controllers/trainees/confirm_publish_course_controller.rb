# frozen_string_literal: true

module Trainees
  class ConfirmPublishCourseController < ApplicationController
    before_action :set_trainee
    before_action :authorize_trainee
    before_action :set_course

    def edit
      page_tracker.save_as_origin!
      @confirm_publish_course_form = ConfirmPublishCourseForm.new(@trainee, specialisms)
    end

    def update
      @confirm_publish_course_form = ConfirmPublishCourseForm.new(@trainee, specialisms, course_params)
      if @confirm_publish_course_form.save
        clear_form_stash(@trainee)
        redirect_to review_draft_trainee_path(@trainee)
      else
        render :edit
      end
    end

  private

    def specialisms
      specialism_form_type = PublishCourseDetailsForm.new(@trainee).specialism_form
      if specialism_form_type == :language
        LanguageSpecialsimsForm.new(@trainee).language_specialisms
      elsif specialism_form_type == :general
        SubjectSpecialismForm.new(@trainee).specialisms
      else
        CalculateSubjectSpecialisms.call(subjects: @course.subjects.pluck(:name))
      end
    end

    def set_trainee
      @trainee = Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(@trainee)
    end

    def set_course
      @course = @trainee.available_courses.find_by_code!(PublishCourseDetailsForm.new(@trainee).code)
    end

    def course_params
      params.fetch(:confirm_publish_course_form, {}).permit(:code)
    end
  end
end
