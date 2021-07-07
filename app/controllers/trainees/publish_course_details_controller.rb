# frozen_string_literal: true

module Trainees
  class PublishCourseDetailsController < ApplicationController
    before_action :authorize_trainee

    def edit
      @courses = @trainee.available_courses
      @publish_course_details = PublishCourseDetailsForm.new(trainee)
    end

    def update
      rerender_page =
        proc do
          @courses = @trainee.available_courses
          render :edit
          return
        end

      @publish_course_details = PublishCourseDetailsForm.new(trainee, params: course_params, user: current_user)

      rerender_page.call unless @publish_course_details.valid?

      redirect_path =
        if @publish_course_details.manual_entry_chosen?
          edit_trainee_course_details_path
        elsif specialism_type == :language
          @publish_course_details.specialism_form = :language
          edit_trainee_language_specialisms_path(@trainee)
        elsif course_has_one_specialism?
          edit_trainee_confirm_publish_course_path(trainee_id: @trainee.slug)
        else
          @publish_course_details.specialism_form = :general
          edit_trainee_subject_specialism_path(@trainee, 1)
        end

      unless @publish_course_details.stash
        rerender_page.call
      end

      if @publish_course_details.manual_entry_chosen?
        trainee.update!(course_code: nil)
      end

      redirect_to redirect_path
    end

  private

    def course_has_one_specialism?
      CalculateSubjectSpecialisms.call(subjects: course_subjects).all? do |_, v|
        v.count < 2
      end
    end

    def specialism_type
      @specialism_type ||= CalculateSubjectSpecialismType.call(subjects: course_subjects)
    end

    def course_subjects
      @course_subjects ||= Course.find_by_code(@publish_course_details.code).subjects.map(&:name)
    end

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
