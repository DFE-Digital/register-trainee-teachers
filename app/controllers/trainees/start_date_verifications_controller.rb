# frozen_string_literal: true

module Trainees
  class StartDateVerificationsController < BaseController
    def show
      @start_date_verification_form = StartDateVerificationForm.new
    end

    def create
      @start_date_verification_form = StartDateVerificationForm.new(verification_params)

      if @start_date_verification_form.valid?
        redirect_to(relevant_redirect_path)
      else
        render(:show)
      end
    end

  private

    def verification_params
      params.require(:start_date_verification_form).permit(:trainee_has_started_course, :context)
    end

    def relevant_redirect_path
      if trainee_started_course? && withdrawing?
        edit_trainee_start_status_path(trainee, context: :withdraw)
      elsif !trainee_started_course? && withdrawing?
        trainee_forbidden_withdrawal_path(trainee)
      elsif trainee_started_course?
        edit_trainee_start_status_path(trainee, context: :delete)
      else
        trainee_confirm_delete_path(trainee)
      end
    end

    def trainee_started_course?
      @start_date_verification_form.already_started?
    end

    def withdrawing?
      @start_date_verification_form.withdrawing?
    end
  end
end
