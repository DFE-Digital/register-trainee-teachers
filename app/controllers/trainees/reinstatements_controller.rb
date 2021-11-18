# frozen_string_literal: true

module Trainees
  class ReinstatementsController < BaseController
    before_action :redirect_to_confirm_reinstatement, if: -> { trainee.starts_course_in_the_future? }

    def show
      @reinstatement_form = ReinstatementForm.new(trainee)
    end

    def update
      authorize(trainee, :reinstate?)

      @reinstatement_form = ReinstatementForm.new(trainee, params: trainee_params, user: current_user)

      if @reinstatement_form.stash
        redirect_to_confirm_reinstatement
      else
        render(:show)
      end
    end

  private

    def trainee_params
      params.require(:reinstatement_form)
        .permit(:date_string, *MultiDateForm::PARAM_CONVERSION.keys)
        .transform_keys do |key|
          MultiDateForm::PARAM_CONVERSION.fetch(key, key)
        end
    end

    def redirect_to_confirm_reinstatement
      redirect_to(trainee_confirm_reinstatement_path(trainee))
    end
  end
end
