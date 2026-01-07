# frozen_string_literal: true

module Trainees
  class StartDateVerificationsController < BaseController
    before_action :redirect_to_confirm_delete, if: :deleting_course_and_not_started?

    def show
      @start_date_verification_form = StartDateVerificationForm.new(trainee, params: params.slice(:context).permit!)
    end

    def update
      @start_date_verification_form = StartDateVerificationForm.new(trainee, params: verification_params, user: current_user)

      if @start_date_verification_form.save!
        redirect_to(relevant_redirect_path)
      else
        render(:show)
      end
    end

  private

    def verification_params
      params.expect(start_date_verification_form: %i[trainee_has_started_course context])
    end

    def relevant_redirect_path
      if trainee_started_course?
        edit_trainee_start_status_path(trainee, context:)
      elsif withdrawing?
        trainee_forbidden_withdrawal_path(trainee)
      elsif deferring?
        trainee_confirm_deferral_path(trainee)
      else
        confirm_delete_path
      end
    end

    def trainee_started_course?
      @start_date_verification_form.already_started?
    end

    def withdrawing?
      @start_date_verification_form.withdrawing?
    end

    def redirect_to_confirm_delete
      redirect_to(confirm_delete_path)
    end

    def confirm_delete_path
      trainee_confirm_delete_path(trainee)
    end

    def deleting_course_and_not_started?
      trainee.starts_course_in_the_future? && params[:context] == StartDateVerificationForm::DELETE
    end

    def deferring?
      @start_date_verification_form.deferring?
    end

    def context
      @start_date_verification_form.context
    end
  end
end
