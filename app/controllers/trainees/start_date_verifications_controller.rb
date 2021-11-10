# frozen_string_literal: true

module Trainees
  class StartDateVerificationsController < BaseController
    def show
      @start_date_verification_form = StartDateVerificationForm.new
    end

    def create
      @start_date_verification_form = StartDateVerificationForm.new(verification_params)

      if @start_date_verification_form.valid?
        if @start_date_verification_form.already_started?
          redirect_to(edit_trainee_start_status_path(trainee, context: :delete))
        else
          redirect_to(trainee_confirm_delete_path(trainee))
        end
      else
        render(:show)
      end
    end

  private

    def verification_params
      params.require(:start_date_verification_form).permit(:trainee_has_started_course)
    end
  end
end
