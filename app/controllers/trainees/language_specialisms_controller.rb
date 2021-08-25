# frozen_string_literal: true

module Trainees
  class LanguageSpecialismsController < ApplicationController
    include PublishCourseNextPath

    before_action :authorize_trainee
    before_action :load_language_specialisms

    def edit
      @language_specialisms_form = LanguageSpecialismsForm.new(trainee)
    end

    def update
      @language_specialisms_form = LanguageSpecialismsForm.new(trainee, params: language_specialism_params, user: current_user)

      save_strategy = trainee.draft? ? :save! : :stash

      if @language_specialisms_form.public_send(save_strategy)
        redirect_to next_step_path
      else
        render :edit
      end
    end

  private

    def next_step_path
      publish_course_next_path
    end

    def load_language_specialisms
      @language_specialisms = PUBLISH_SUBJECT_SPECIALISM_MAPPING[PublishSubjects::MODERN_LANGUAGES]
    end

    def language_specialism_params
      params.fetch(:language_specialisms_form, {}).permit(language_specialisms: [])
    end

    def authorize_trainee
      authorize(trainee)
    end

    def course_code
      publish_course_details_form.code || trainee.course_code
    end
  end
end
