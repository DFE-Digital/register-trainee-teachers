# frozen_string_literal: true

module Trainees
  class ConfirmPublishCourseController < ApplicationController
    include PublishCourseNextPath

    before_action :authorize_trainee, :course

    def edit
      page_tracker.save_as_origin!
      @confirm_publish_course_form = ConfirmPublishCourseForm.new(trainee, specialisms, itt_start_date, course_study_mode)
    end

    def update
      @confirm_publish_course_form = ConfirmPublishCourseForm.new(trainee, specialisms, itt_start_date, course_study_mode, course_params)
      if @confirm_publish_course_form.save
        clear_form_stash(trainee)
        redirect_to review_draft_trainee_path(trainee)
      else
        render :edit
      end
    end

  private

    def course_study_mode
      @course_study_mode ||= if trainee.requires_study_mode?
                               StudyModesForm.new(trainee).study_mode
                             end
    end

    def itt_start_date
      @itt_start_date ||= if trainee.requires_itt_start_date?
                            IttStartDateForm.new(trainee).date
                          end
    end

    def specialisms
      specialism_form_type = PublishCourseDetailsForm.new(trainee).specialism_form&.to_sym
      @specialisms ||=
        case specialism_form_type
        when :language
          LanguageSpecialismsForm.new(trainee).languages
        when :general
          SubjectSpecialismForm.new(trainee).specialisms
        else
          CalculateSubjectSpecialisms.call(subjects: course.subjects.pluck(:name)).values.map(&:first).compact
        end
    end

    def authorize_trainee
      authorize(trainee)
    end

    def course_code
      publish_course_details_form.code
    end

    def course_params
      params.fetch(:confirm_publish_course_form, {}).permit(:code)
    end
  end
end
