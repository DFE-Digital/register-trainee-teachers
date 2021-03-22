# frozen_string_literal: true

module Trainees
  class ReinstatementsController < ApplicationController
    before_action :authorize_trainee

    def show
      @reinstatement_form = ReinstatementForm.new(trainee)
    end

    def update
      authorize(trainee, :reinstate?)

      @reinstatement_form = ReinstatementForm.new(trainee, trainee_params)

      if @reinstatement_form.stash
        redirect_to trainee_confirm_reinstatement_path(@trainee)
      else
        render :show
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee)
    end

    def trainee_params
      params.require(:reinstatement_form)
        .permit(:date_string, *MultiDateForm::PARAM_CONVERSION.keys)
        .transform_keys do |key|
          MultiDateForm::PARAM_CONVERSION.fetch(key, key)
        end
    end
  end
end
