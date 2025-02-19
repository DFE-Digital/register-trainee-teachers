# frozen_string_literal: true

module Trainees
  class LanguageSpecialismsController < BaseController
    include Publishable

    before_action :setup_form
    before_action :skip_manual_selection, if: :course_has_one_language_specialism?

    def edit; end

    def update
      if @language_specialisms_form.stash_or_save!
        redirect_to(next_path_after_update(trainee))
      else
        render(:edit)
      end
    end

    delegate :non_language_subject, to: :@language_specialisms_form

    helper_method :non_language_subject

  private

    def setup_form
      @language_specialisms_form = LanguageSpecialismsForm.new(
        trainee,
        params: language_specialism_params,
        user: current_user,
      )
    end

    def next_path_after_update(trainee)
      if non_language_subject
        edit_trainee_subject_specialism_path(trainee, language_specialisms_count + 1)
      else
        edit_trainee_course_details_study_mode_path(trainee)
      end
    end

    def language_specialisms_count
      language_specialism_params.values.count
    end

    def skip_manual_selection
      LanguageSpecialismsForm.new(trainee, params: {
        language_specialisms: subject_specialisms[:course_subject_one],
      }).stash_or_save!

      redirect_to(next_path_after_update(trainee))
    end

    def course_has_one_language_specialism?
      subject_specialisms.all? { |_, v| v.count < 2 }
    end

    def language_specialism_params
      params.fetch(:language_specialisms_form, {}).permit(
        %i[course_subject_one course_subject_two course_subject_three],
      )
    end

    def course_uuid
      publish_course_details_form.course_uuid || trainee.course_uuid
    end

    def subject_specialisms
      @subject_specialisms ||= CalculateSubjectSpecialisms.call(subjects: course_subjects)
    end

    def course_subjects
      @course_subjects ||= course.subjects.pluck(:name)
    end
  end
end
