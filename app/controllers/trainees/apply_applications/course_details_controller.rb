# frozen_string_literal: true

module Trainees
  module ApplyApplications
    class CourseDetailsController < BaseController
      before_action :set_course
      before_action :redirect_to_confirm_page, if: :already_confirmed_course?
      before_action :redirect_to_publish_course_details_path, if: :course_not_found?

      def edit
        @review_course_form = ::ApplyApplications::ReviewCourseForm.new
      end

      def update
        @review_course_form = ::ApplyApplications::ReviewCourseForm.new(review_course_params)

        if @review_course_form.valid?
          return save_course_and_continue if @review_course_form.registered?

          redirect_to(edit_trainee_training_route_path(trainee, context: "edit-course"))
        else
          render(:edit)
        end
      end

    private

      def review_course_params
        params.require(:apply_applications_review_course_form).permit(
          *::ApplyApplications::ReviewCourseForm::FIELDS,
        )
      end

      def set_course
        @course = trainee.published_course
      end

      def subject_specialism_path
        return edit_trainee_language_specialisms_path(trainee) if language_specialism?

        edit_trainee_subject_specialism_path(trainee, 1)
      end

      def language_specialism?
        %i[language language_and_other].include?(specialism_type)
      end

      def specialism_type
        @specialism_type ||= CalculateSubjectSpecialismType.call(subjects: course_subjects)
      end

      def course_has_one_specialism?
        specialisms.all? { |_, v| v.count < 2 }
      end

      def specialisms
        @specialisms ||= CalculateSubjectSpecialisms.call(subjects: course_subjects)
      end

      def course_subjects
        @course_subjects ||= @course.subjects.pluck(:name)
      end

      def redirect_to_confirm_page
        redirect_to(trainee_apply_applications_confirm_courses_path(trainee))
      end

      def redirect_to_publish_course_details_path
        redirect_to(edit_trainee_publish_course_details_path(trainee))
      end

      def save_course_and_continue
        save_course
        redirect_to_relevant_step
      end

      def save_course
        ::ApplyApplications::ConfirmCourseForm.new(
          trainee,
          course_has_one_specialism? ? specialisms : [],
          { uuid: review_course_params[:uuid] },
        ).save
      end

      def redirect_to_relevant_step
        if specialisms.size > 1
          redirect_to(subject_specialism_path)
        else
          redirect_to(trainee_apply_applications_confirm_courses_path(trainee))
        end
      end

      def already_confirmed_course?
        trainee.course_subjects.any?
      end

      def course_not_found?
        @course.blank?
      end
    end
  end
end
