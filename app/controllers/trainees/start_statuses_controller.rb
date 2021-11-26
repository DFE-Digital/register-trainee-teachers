# frozen_string_literal: true

module Trainees
  class StartStatusesController < BaseController
    PARAM_CONVERSION = {
      "commencement_date(3i)" => "day",
      "commencement_date(2i)" => "month",
      "commencement_date(1i)" => "year",
    }.freeze

    def edit
      @trainee_start_status_form = TraineeStartStatusForm.new(trainee)
    end

    def update
      @trainee_start_status_form = TraineeStartStatusForm.new(trainee, params: trainee_params, user: current_user)

      if @trainee_start_status_form.public_send(context_present? ? :save! : :stash_or_save!)
        return redirect_to(trainee_forbidden_deletes_path(trainee)) if delete_context?
        return redirect_to(trainee_withdrawal_path(trainee)) if withdraw_context?

        if trainee.draft? && trainee.submission_ready?
          Trainees::SubmitForTrn.call(trainee: trainee, dttp_id: current_user.dttp_id)
          return redirect_to(trn_submission_path(trainee))
        end

        redirect_to(trainee_start_status_confirm_path(trainee))
      else
        render(:edit)
      end
    end

  private

    def trainee_params
      params.require(:trainee_start_status_form).permit(
        *TraineeStartStatusForm::FIELDS,
        *PARAM_CONVERSION.keys,
      ).transform_keys do |key|
        PARAM_CONVERSION.keys.include?(key) ? PARAM_CONVERSION[key] : key
      end
    end

    def delete_context?
      params[:context] == StartDateVerificationForm::DELETE
    end

    def withdraw_context?
      params[:context] == StartDateVerificationForm::WITHDRAW
    end

    def context_present?
      params[:context].present?
    end
  end
end
