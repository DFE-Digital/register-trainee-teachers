# frozen_string_literal: true

module Trainees
  class ConfirmWithdrawalsController < BaseController
    def show
      page_tracker.save_as_origin!
      withdrawal
    end

    def update
      if withdrawal.save!
        trainee.withdraw!
        Dttp::WithdrawJob.perform_later(trainee)

        flash[:success] = I18n.t("flash.trainee_withdrawn")
        redirect_to(trainee_path(trainee))
      end
    end

  private

    def withdrawal
      @withdrawal ||= WithdrawalForm.new(trainee)
    end
  end
end
