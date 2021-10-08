# frozen_string_literal: true

module Trainees
  class SubjectSpecialismsController < ApplicationController
    include PublishCourseNextPath

    before_action :authorize_trainee

    helper_method :position, :course_subject_attribute_name

    def edit
      @specialisms = subject_specialisms_for_position(position)

      if @specialisms.count == 1
        SubjectSpecialismForm.new(trainee, position, params: {
          course_subject_attribute_name => @specialisms.first,
        }).stash_or_save!

        return redirect_to(next_step_path)
      end

      @subject = course_subjects[position - 1]
      @subject_specialism_form = SubjectSpecialismForm.new(trainee, position)
    end

    def update
      @subject_specialism_form = SubjectSpecialismForm.new(trainee, position, params: specialism_params)

      if @subject_specialism_form.stash_or_save!
        redirect_to(next_step_path)
      else
        @subject = course_subjects[position - 1]
        @specialisms = subject_specialisms_for_position(position)

        render(:edit)
      end
    end

  private

    def position
      params[:position].to_i
    end

    def specialism_params
      return {} if params[:subject_specialism_form].blank?

      params
        .require(:subject_specialism_form)
        .permit(course_subject_attribute_name, course_subject_attribute_name => [])
        .transform_values(&:first)
    end

    def next_step_path
      next_position = position + 1

      if subject_specialisms_for_position(next_position).present?
        edit_trainee_subject_specialism_path(trainee, next_position)
      else
        publish_course_next_path
      end
    end

    def course_code
      publish_course_details_form.course_code || trainee.course_code
    end

    def subject_specialisms_for_position(position)
      subject_specialisms[course_subject_attribute_name(position)]
    end

    def course_subject_attribute_name(number = position)
      "course_subject_#{number_in_words(number)}".to_sym
    end

    def number_in_words(number)
      case number
      when 1 then "one"
      when 2 then "two"
      when 3 then "three"
      end
    end

    def subject_specialisms
      @subject_specialisms ||= CalculateSubjectSpecialisms.call(subjects: course_subjects)
    end

    def course_subjects
      @course_subjects ||= course.subjects.pluck(:name)
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
