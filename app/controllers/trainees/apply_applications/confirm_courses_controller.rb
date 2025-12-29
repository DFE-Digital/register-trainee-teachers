# frozen_string_literal: true

module Trainees
  module ApplyApplications
    class ConfirmCoursesController < BaseController
      before_action :redirect_to_manual_confirm_page, if: :manual_entry_chosen?
      before_action :set_course, :set_specialisms

      helper_method :course_uuid

      def show
        page_tracker.save_as_origin!
        @confirm_course_form = ::ApplyApplications::ConfirmCourseForm.new(trainee, @specialisms)
      end

      def update
        @confirm_course_form = ::ApplyApplications::ConfirmCourseForm.new(trainee, @specialisms, course_params)

        if @confirm_course_form.save
          clear_form_stash(trainee)
          redirect_to(trainee_review_drafts_path(trainee))
        else
          render(:show)
        end
      end

    private

      def redirect_to_manual_confirm_page
        redirect_to(trainee_course_details_confirm_path(trainee))
      end

      def set_course
        @course = trainee.available_courses.find_by(code: course_uuid)
      end

      def set_specialisms
        @specialisms = if trainee.course_subjects.any? && publish_course_details_form.course_uuid.nil?
                         trainee.course_subjects
                       else
                         selected_or_calculated_specialisms
                       end
      end

      def course_params
        params
              .expect(apply_applications_confirm_course_form: [*::ApplyApplications::ConfirmCourseForm::FIELDS])
      end

      def course_uuid
        publish_course_details_form.course_uuid || trainee.course_uuid
      end

      def publish_course_details_form
        @publish_course_details_form ||= PublishCourseDetailsForm.new(trainee)
      end

      def selected_or_calculated_specialisms
        if publish_course_details_form.selected_specialisms.any?
          publish_course_details_form.selected_specialisms
        else
          CalculateSubjectSpecialisms.call(subjects: @course.subjects.pluck(:name)).values.map(&:first).compact
        end
      end

      def manual_entry_chosen?
        publish_course_details_form.manual_entry_chosen? || trainee.course_uuid.blank?
      end
    end
  end
end
