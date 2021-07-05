# frozen_string_literal: true

module Trainees
  class SubjectSpecialismsController < ApplicationController
    before_action :authorize_trainee
    helper_method :position

    def edit
      course = Course.first
      @subject = course.subjects[position - 1].name
      @specialisms = CalculateSubjectSpecialisms.call(subjects: course.subjects.map(&:name))[:"course_subject_#{position_in_words}"]
      @subject_specialism_form = SubjectSpecialismForm.new(trainee, position)
    end

    def update
      @subject_specialism_form = SubjectSpecialismForm.new(trainee, position, params: specialism_params)
      save_strategy = trainee.draft? ? :save! : :stash

      if @subject_specialism_form.public_send(save_strategy)
        redirect_to next_step_path
      else
        course = Course.first
        @subject = course.subjects[position - 1].name
        @specialisms = CalculateSubjectSpecialisms.call(subjects: course.subjects.map(&:name))[:"course_subject_#{position_in_words}"]
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def position
      params[:position].to_i
    end

    def position_in_words
      @_position_in_words ||= to_word(position)
    end

    def to_word(number)
      case number
      when 1
        "one"
      when 2
        "two"
      when 3
        "three"
      end
    end

    def authorize_trainee
      authorize(trainee)
    end

    def specialism_params
      params.require(:subject_specialism_form).permit(:"specialism#{position}")
    end

    def next_step_path
      course = Course.first
      specialisms = CalculateSubjectSpecialisms.call(subjects: course.subjects.map(&:name))
      next_position = position + 1
      if specialisms[:"course_subject_#{to_word(next_position)}"].present?
        edit_trainee_subject_specialism_path(@trainee, next_position)
      else
        # TODO: redirect to confirm path when it exists
        "www.example.com"
      end
    end
  end
end
