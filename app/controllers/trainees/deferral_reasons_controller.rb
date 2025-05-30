# frozen_string_literal: true

module Trainees
  class DeferralReasonsController < BaseController
    def show
      @deferral_form = DeferralForm.new(trainee)
    end

    def update
      @deferral_form = DeferralForm.new(trainee, params: trainee_params, user: current_user)

      if @deferral_form.stash
        redirect_to_confirm_deferral
      else
        render(:show)
      end
    end

  private

    def trainee_params
      params.require(:deferral_form)
        .permit(:defer_reason, :date_string, *MultiDateForm::PARAM_CONVERSION.keys)
        .transform_keys do |key|
          MultiDateForm::PARAM_CONVERSION.fetch(key, key)
        end
    end

    def redirect_to_confirm_deferral
      redirect_to(trainee_confirm_deferral_path(trainee))
    end

    def authorize_trainee
      authorize(trainee, :defer?)
    end
  end
end
