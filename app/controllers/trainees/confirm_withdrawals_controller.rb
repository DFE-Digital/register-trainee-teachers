# frozen_string_literal: true

module Trainees
  class ConfirmWithdrawalsController < Trainees::BaseController
    helper_method :trainee, :form

    def show; end

    def update
      if form.save!
        trainee.withdraw! unless trainee.withdrawn?
        flash[:success] = I18n.t("flash.trainee_withdrawn")
        redirect_to(trainee_path(trainee))
      end
    end

  private

    def form
      @form ||= Withdrawal::ConfirmationForm.new(trainee)
    end
  end
end
