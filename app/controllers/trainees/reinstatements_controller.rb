# frozen_string_literal: true

module Trainees
  class ReinstatementsController < BaseController
    before_action :redirect_to_confirm_reinstatement, if: -> { trainee.starts_course_in_the_future? }

    def show
      @reinstatement_form = ReinstatementForm.new(trainee)
    end

    def update
      @reinstatement_form = ReinstatementForm.new(trainee, params: trainee_params, user: current_user)

      if @reinstatement_form.stash
        redirect_to(trainee_reinstatement_update_end_date_path(trainee))
      else
        render(:show)
      end
    end

  private

    def trainee_params
      params
        .expect(reinstatement_form: [:date_string, *MultiDateForm::PARAM_CONVERSION.keys])
        .transform_keys do |key|
          MultiDateForm::PARAM_CONVERSION.fetch(key, key)
        end
    end

    def authorize_trainee
      authorize(trainee, :reinstate?)
    end
  end
end
