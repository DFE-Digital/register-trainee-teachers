# frozen_string_literal: true

module Trainees
  class SubjectSpecialismsController < ApplicationController
    before_action :authorize_trainee
    helper_method :position

    def edit
      # PITA
      course = Course.find(10)
      @subject = course.subjects[position - 1].name
      @specialisms = CalculateSubjectSpecialisms.call(subjects: course.subjects.map(&:name))[:"course_subject_#{position_in_words}"]
      @select_specialism_form = SelectSpecialismForm.new(trainee, position)
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def position
      params[:position].to_i
    end

    def position_in_words
      @_piw ||= to_word(position)
    end

    def to_word(number)
      case number
      when 1
        "one"
      when 2
        "two"
      when
        "three"
      end
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
