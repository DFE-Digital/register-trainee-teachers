# frozen_string_literal: true

module Trainees
  module ApplyApplications
    class CourseDetailsController < ApplicationController
      before_action :authorize_trainee
      before_action :set_course
      before_action :redirect_to_confirm_page, if: :manual_specialism_selection_unnecessary?

      helper_method :subject_specialism_path

      def show; end

    private

      def set_course
        @course = trainee.available_courses.find_by(code: trainee.course_code)
      end

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def authorize_trainee
        authorize(trainee)
      end

      def subject_specialism_path
        if course_has_one_specialism?
          trainee_apply_applications_confirm_courses_path(trainee)
        elsif specialism_type == :language
          edit_trainee_language_specialisms_path(trainee)
        else
          edit_trainee_subject_specialism_path(trainee, 1)
        end
      end

      def specialism_type
        @specialism_type ||= CalculateSubjectSpecialismType.call(subjects: course_subjects)
      end

      def course_has_one_specialism?
        CalculateSubjectSpecialisms.call(subjects: course_subjects).all? { |_, v| v.count < 2 }
      end

      def course_subjects
        @course_subjects ||= @course.subjects.pluck(:name)
      end

      def redirect_to_confirm_page
        redirect_to trainee_apply_applications_confirm_courses_path(trainee)
      end

      def manual_specialism_selection_unnecessary?
        trainee.course_subjects.any? || course_has_one_specialism?
      end
    end
  end
end
