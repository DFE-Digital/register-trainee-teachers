# frozen_string_literal: true

module Trainees
  class SubjectSpecialismsController < ApplicationController
    before_action :authorize_trainee
    before_action :load_subject_specialisms

    def edit
      @subject_specialisms_form = LanguageSubjectSpecialismsForm.new(trainee)
    end

    def update
      @subject_specialisms_form = LanguageSubjectSpecialismsForm.new(trainee, params: subject_specialism_params, user: current_user)

      save_strategy = trainee.draft? ? :save! : :stash

      if @subject_specialisms_form.public_send(save_strategy)
        # TODO: do something
      else
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def course
      trainee.available_courses.find_by!(code: course_code)
    end

    def course_code
      params[:course_code] || params[:language_subject_specialisms_form][:course_code]
    end

    def load_subject_specialisms
      @subject_specialisms = CalculateSubjectSpecialisms.call(subjects: course.subjects.pluck(:name))[:course_subject_one]
    end

    def subject_specialism_params
      params.fetch(:language_subject_specialisms_form, {}).permit(subject_specialisms: [])
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
