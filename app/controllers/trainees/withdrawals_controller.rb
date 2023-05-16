# frozen_string_literal: true

module Trainees
  class WithdrawalsController < BaseController
    def show
      @withdrawal_form = WithdrawalForm.new(trainee)
    end

    def update
      @withdrawal_form = WithdrawalForm.new(trainee, params: trainee_params, user: current_user)

      if @withdrawal_form.stash
        redirect_to(trainee_confirm_withdrawal_path(@trainee))
      else
        render(:show)
      end
    end

  private

    def trainee_params
      params.require(:withdrawal_form)
        .permit(:date_string, :withdraw_reason, :additional_withdraw_reason, *MultiDateForm::PARAM_CONVERSION.keys)
        .transform_keys do |key|
          MultiDateForm::PARAM_CONVERSION.fetch(key, key)
        end
    end

    def authorize_trainee
      authorize(trainee, :withdraw?)
    end
  end
end
