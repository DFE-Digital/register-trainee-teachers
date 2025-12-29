# frozen_string_literal: true

module Trainees
  class OutcomeDatesController < BaseController
    def edit
      @outcome_form = OutcomeDateForm.new(trainee)
    end

    def update
      @outcome_form = OutcomeDateForm.new(trainee, params: trainee_params, user: current_user)

      if @outcome_form.stash
        redirect_to(confirm_trainee_outcome_details_path(trainee))
      else
        render(:edit)
      end
    end

  private

    def trainee_params
      params
        .expect(outcome_date_form: [:date_string, *MultiDateForm::PARAM_CONVERSION.keys])
        .transform_keys do |key|
          MultiDateForm::PARAM_CONVERSION.fetch(key, key)
        end
    end

    def authorize_trainee
      authorize(trainee, :recommend_for_award?)
    end
  end
end
