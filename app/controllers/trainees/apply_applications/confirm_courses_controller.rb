# frozen_string_literal: true

module Trainees
  module ApplyApplications
    class ConfirmCoursesController < ApplicationController
      before_action :authorize_trainee
      before_action :redirect_to_manual_confirm_page, if: :manual_entry_chosen?
      before_action :set_course
      before_action :set_specialisms
      helper_method :course_code
      before_action :set_itt_start_date

      def show
        page_tracker.save_as_origin!
        @confirm_course_form = ::ApplyApplications::ConfirmCourseForm.new(trainee, @specialisms, @itt_start_date)
      end

      def update
        @confirm_course_form = ::ApplyApplications::ConfirmCourseForm.new(trainee, @specialisms, @itt_start_date, course_params)

        if @confirm_course_form.save
          clear_form_stash(trainee)
          redirect_to review_draft_trainee_path(trainee)
        else
          render :show
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def redirect_to_manual_confirm_page
        redirect_to trainee_course_details_confirm_path(trainee)
      end

      def set_course
        @course = trainee.available_courses.find_by(code: course_code)
      end

      def set_itt_start_date
        @itt_start_date = if @trainee.requires_itt_start_date?
                            IttStartDateForm.new(@trainee).date
                          end
      end

      def set_specialisms
        @specialisms = if trainee.course_subjects.any? && publish_course_details_form.course_code.nil?
                         trainee.course_subjects
                       else
                         selected_or_calculated_specialisms
                       end
      end

      def authorize_trainee
        authorize(trainee)
      end

      def course_params
        params.require(:apply_applications_confirm_course_form)
              .permit(*::ApplyApplications::ConfirmCourseForm::FIELDS)
      end

      def course_code
        publish_course_details_form.course_code || trainee.course_code
      end

      def publish_course_details_form
        @publish_course_details_form ||= PublishCourseDetailsForm.new(trainee)
      end

      def selected_or_calculated_specialisms
        return selected_specialisms if publish_course_details_form.general_specialism? || selected_specialisms&.any?
        return selected_language_specialisms if publish_course_details_form.language_specialism? || selected_language_specialisms&.any?

        CalculateSubjectSpecialisms.call(subjects: @course.subjects.pluck(:name)).values.map(&:first).compact
      end

      def selected_specialisms
        @selected_specialisms ||= SubjectSpecialismForm.new(trainee).specialisms
      end

      def selected_language_specialisms
        @selected_language_specialisms ||= LanguageSpecialismsForm.new(trainee).languages
      end

      def manual_entry_chosen?
        publish_course_details_form.manual_entry_chosen? || trainee.course_code.blank?
      end
    end
  end
end
