# frozen_string_literal: true

module Trainees
  class StartDatesController < BaseController
    PARAM_CONVERSION = {
      "trainee_start_date(3i)" => "day",
      "trainee_start_date(2i)" => "month",
      "trainee_start_date(1i)" => "year",
    }.freeze

    def edit
      redirect_to(edit_trainee_start_status_path(trainee)) if @trainee.trainee_start_date.blank?
      @trainee_start_date_form = TraineeStartDateForm.new(trainee, params: params.slice(:context).permit!)
    end

    def update
      @trainee_start_date_form = TraineeStartDateForm.new(trainee, params: trainee_params, user: current_user)

      if @trainee_start_date_form.stash_or_save!
        redirect_to(relevant_redirect_path)
      else
        render(:edit)
      end
    end

  private

    def trainee_params
      params.require(:trainee_start_date_form).permit(:trainee_start_date, :context, *PARAM_CONVERSION.keys)
        .transform_keys do |key|
          PARAM_CONVERSION.keys.include?(key) ? PARAM_CONVERSION[key] : key
        end
    end

    def relevant_redirect_path
      if @trainee_start_date_form.deferring?
        return trainee_deferral_path(trainee) if @trainee_start_date_form.itt_start_date_is_after_deferral_date?

        return trainee_confirm_deferral_path(trainee)
      end

      trainee_start_date_confirm_path(trainee)
    end
  end
end
