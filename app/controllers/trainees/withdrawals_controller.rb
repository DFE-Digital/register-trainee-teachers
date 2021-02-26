# frozen_string_literal: true

module Trainees
  class WithdrawalsController < ApplicationController
    before_action :authorize_trainee

    def show
      @withdrawal_form = WithdrawalForm.new(trainee)
    end

    def update
      authorize(trainee, :withdraw?)

      @withdrawal_form = WithdrawalForm.new(trainee)
      @withdrawal_form.assign_attributes(trainee_params)

      if @withdrawal_form.save
        redirect_to trainee_confirm_withdrawal_path(@trainee)
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
      params.require(:withdrawal_form)
        .permit(:date_string, :withdraw_reason, :additional_withdraw_reason, *MultiDateForm::PARAM_CONVERSION.keys)
        .transform_keys do |key|
          MultiDateForm::PARAM_CONVERSION.fetch(key, key)
        end
    end
  end
end
