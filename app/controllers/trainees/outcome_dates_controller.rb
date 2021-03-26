# frozen_string_literal: true

module Trainees
  class OutcomeDatesController < ApplicationController
    before_action :authorize_trainee

    def edit
      @outcome_form = OutcomeDateForm.new(trainee)
    end

    def update
      @outcome_form = OutcomeDateForm.new(trainee, trainee_params)

      if @outcome_form.stash
        redirect_to confirm_trainee_outcome_details_path(trainee)
      else
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def trainee_params
      params.require(:outcome_date_form)
        .permit(:date_string, *MultiDateForm::PARAM_CONVERSION.keys)
        .transform_keys do |key|
          MultiDateForm::PARAM_CONVERSION.fetch(key, key)
        end
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
