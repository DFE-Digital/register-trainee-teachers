# frozen_string_literal: true

module Trainees
  class DeferralsController < ApplicationController
    before_action :authorize_trainee

    def show
      @deferral = DeferralForm.new(trainee)
    end

    def update
      authorize(trainee, :defer?)

      @deferral = DeferralForm.new(trainee)
      @deferral.assign_attributes(trainee_params)

      if @deferral.save
        redirect_to trainee_confirm_deferral_path(trainee)
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
      params.require(:deferral_form)
        .permit(:date_string, *MultiDateForm::PARAM_CONVERSION.keys)
        .transform_keys do |key|
          MultiDateForm::PARAM_CONVERSION.fetch(key, key)
        end
    end
  end
end
