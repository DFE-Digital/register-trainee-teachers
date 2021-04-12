# frozen_string_literal: true

module Trainees
  class DeferralsController < ApplicationController
    before_action :authorize_trainee

    def show
      @deferral_form = DeferralForm.new(trainee)
    end

    def update
      authorize(trainee, :defer?)

      @deferral_form = DeferralForm.new(trainee, params: trainee_params, user: current_user)

      if @deferral_form.stash
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
