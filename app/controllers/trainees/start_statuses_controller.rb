# frozen_string_literal: true

module Trainees
  class StartStatusesController < BaseController
    PARAM_CONVERSION = {
      "trainee_start_date(3i)" => "day",
      "trainee_start_date(2i)" => "month",
      "trainee_start_date(1i)" => "year",
    }.freeze

    def edit
      @trainee_start_status_form = TraineeStartStatusForm.new(trainee, params: params.slice(:context).permit!)
    end

    def update
      @trainee_start_status_form = TraineeStartStatusForm.new(trainee, params: trainee_params, user: current_user)

      if @trainee_start_status_form.stash_or_save!
        if trainee.draft? && trainee.submission_ready?
          Trainees::SubmitForTrn.call(trainee:)
          return redirect_to(trn_submission_path(trainee))
        end

        redirect_to(relevant_redirect_path)
      else
        render(:edit)
      end
    end

  private

    def trainee_params
      params.expect(
        trainee_start_status_form: TraineeStartStatusForm::FIELDS + PARAM_CONVERSION.keys,
      ).transform_keys do |key|
        PARAM_CONVERSION.keys.include?(key) ? PARAM_CONVERSION[key] : key
      end
    end

    def relevant_redirect_path
      return trainee_forbidden_deletes_path(trainee) if @trainee_start_status_form.deleting?

      if trainee_start_date_before_withdrawal_date?
        @trainee_start_status_form.save!

        return edit_trainee_withdrawal_confirm_detail_path(trainee)
      end

      return edit_trainee_withdrawal_date_path(trainee) if @trainee_start_status_form.withdrawing?

      if @trainee_start_status_form.deferring?
        return trainee_deferral_path(trainee) if @trainee_start_status_form.needs_deferral_date?

        return trainee_confirm_deferral_path(trainee)
      end

      trainee_start_status_confirm_path(trainee)
    end

    def trainee_start_date_before_withdrawal_date?
      withdrawal_date = ::Withdrawal::DateForm.new(trainee).date

      return false unless withdrawal_date

      @trainee_start_status_form.withdrawing? && @trainee_start_status_form.trainee_start_date < withdrawal_date
    end
  end
end
