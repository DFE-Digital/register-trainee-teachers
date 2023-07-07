# frozen_string_literal: true

module Trainees
  class LanguageSpecialismsController < BaseController
    include Publishable

    before_action :skip_manual_selection, if: :course_has_one_language_specialism?

    def edit
      @language_specialisms_form = LanguageSpecialismsForm.new(trainee)
    end

    def update
      @language_specialisms_form = LanguageSpecialismsForm.new(trainee,
                                                               params: language_specialism_params,
                                                               user: current_user)

      if @language_specialisms_form.stash_or_save!
        redirect_to(edit_trainee_course_details_study_mode_path(trainee))
      else
        render(:edit)
      end
    end

  private

    def skip_manual_selection
      LanguageSpecialismsForm.new(trainee, params: {
        language_specialisms: subject_specialisms[:course_subject_one],
      }).stash_or_save!

      redirect_to(edit_trainee_course_details_study_mode_path(trainee))
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
