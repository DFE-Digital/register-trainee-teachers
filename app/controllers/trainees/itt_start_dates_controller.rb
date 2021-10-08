# frozen_string_literal: true

module Trainees
  class IttStartDatesController < BaseController
    include PublishCourseNextPath

    def edit
      @itt_start_date_form = IttStartDateForm.new(trainee)
    end

    def update
      @itt_start_date_form = IttStartDateForm.new(trainee, params: trainee_params, user: current_user)
      if @itt_start_date_form.stash_or_save!
        redirect_to(study_mode_or_confirmation_path)
      else
        render(:edit)
      end
    end

  private

    def trainee_params
      params.require(:itt_start_date_form)
        .permit(:date_string, *MultiDateForm::PARAM_CONVERSION.keys)
        .transform_keys do |key|
          MultiDateForm::PARAM_CONVERSION.fetch(key, key)
        end.merge({ date_string: :other })
    end

    def course_code
      publish_course_details_form.course_code
    end

    def authorize_trainee
      authorize(trainee, :requires_itt_start_date?)
    end
  end
end
