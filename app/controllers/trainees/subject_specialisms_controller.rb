# frozen_string_literal: true

module Trainees
  class SubjectSpecialismsController < BaseController
    include Publishable

    helper_method :position, :course_subject_attribute_name

    def edit
      @specialisms = subject_specialisms_for_position(position)

      if @specialisms.one?
        SubjectSpecialismForm.new(trainee, position, params: {
          course_subject_attribute_name => @specialisms.first,
        }).stash_or_save!

        return redirect_to(next_step_path)
      end

      @subject = subject_for_position(position)
      @subject_specialism_form = SubjectSpecialismForm.new(trainee, position)
    end

    def update
      @subject_specialism_form = SubjectSpecialismForm.new(trainee, position, params: specialism_params)

      if @subject_specialism_form.stash_or_save!
        redirect_to(next_step_path)
      else
        @subject = subject_for_position(position)
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
        .expect(subject_specialism_form: [course_subject_attribute_name, { course_subject_attribute_name => [] }])
        .transform_values(&:first)
    end

    def next_step_path
      next_position = position + 1

      if subject_specialisms_for_position(next_position).present?
        edit_trainee_subject_specialism_path(trainee, next_position)
      else
        edit_trainee_course_details_study_mode_path(trainee)
      end
    end

    def course_uuid
      publish_course_details_form.course_uuid || trainee.course_uuid
    end

    def subject_specialisms_for_position(position)
      # Fetch the specialisms for the given position
      specialisms = subject_specialisms[course_subject_attribute_name(position)]

      # If there are no specialisms in the given position and the first
      # course is a modern language and the position is 3, then use the
      # specialisms for the previous position instead
      if specialisms.blank? && first_course_is_modern_language? && position == 3
        specialisms = subject_specialisms[course_subject_attribute_name(position - 1)]
      end

      specialisms
    end

    def subject_for_position(position)
      # Fetch the subject for the given position
      @subject = course_subjects[position - 1]

      # If there is no subject in the given position and the first course is
      # a modern language and the position is 3, then use the subject for the
      # previous position instead
      if @subject.blank? && first_course_is_modern_language? && position == 3
        @subject = course_subjects[position - 2]
      end

      @subject
    end

    def first_course_is_modern_language?
      course_subjects.first.downcase.include?("modern")
    end

    def course_subject_attribute_name(number = position)
      :"course_subject_#{number_in_words(number)}"
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
  end
end
