# frozen_string_literal: true

module Trainees
  class WithdrawalsController < ApplicationController
    before_action :authorize_trainee

    PARAM_DATE_CONVERSION = {
      "withdraw_date(3i)" => "day",
      "withdraw_date(2i)" => "month",
      "withdraw_date(1i)" => "year",
    }.freeze

    def show
      @withdrawal_form = WithdrawalForm.new(trainee)
    end

    def update
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
      @trainee ||= Trainee.find(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee)
    end

    def trainee_params
      params.require(:withdrawal_form).permit(:withdraw_date_string,
                                              :withdraw_reason,
                                              :additional_withdraw_reason,
                                              *PARAM_DATE_CONVERSION.keys).transform_keys do |key|
        PARAM_DATE_CONVERSION.fetch(key, key)
      end
    end
  end
end
