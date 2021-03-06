# frozen_string_literal: true

module Trainees
  class LanguageSpecialismsController < ApplicationController
    before_action :authorize_trainee
    before_action :load_language_specialisms

    def edit
      @language_specialisms_form = LanguageSpecialismsForm.new(trainee)
    end

    def update
      @language_specialisms_form = LanguageSpecialismsForm.new(trainee, params: language_specialism_params, user: current_user)

      save_strategy = trainee.draft? ? :save! : :stash

      if @language_specialisms_form.public_send(save_strategy)
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
      params[:course_code] || params[:language_specialisms_form][:course_code]
    end

    def load_language_specialisms
      @language_specialisms = CalculateSubjectSpecialisms.call(subjects: course.subjects.pluck(:name))[:course_subject_one]
    end

    def language_specialism_params
      params.fetch(:language_specialisms_form, {}).permit(language_specialisms: [])
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
