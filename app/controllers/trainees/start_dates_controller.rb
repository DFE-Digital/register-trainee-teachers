# frozen_string_literal: true

module Trainees
  class StartDatesController < BaseController
    PARAM_CONVERSION = {
      "commencement_date(3i)" => "day",
      "commencement_date(2i)" => "month",
      "commencement_date(1i)" => "year",
    }.freeze

    def edit
      redirect_to(edit_trainee_start_status_path(trainee)) if @trainee.commencement_date.blank?
      @trainee_start_date_form = TraineeStartDateForm.new(trainee, params: params.slice(:context).permit!)
    end

    def update
      @trainee_start_date_form = TraineeStartDateForm.new(trainee, params: trainee_params, user: current_user)

      if @trainee_start_date_form.stash_or_save!
        if defer_context?
          redirect_to(trainee_deferral_path(trainee))
        else
          redirect_to(trainee_start_date_confirm_path(trainee))
        end
      else
        render(:edit)
      end
    end

  private

    def trainee_params
      params.require(:trainee_start_date_form).permit(:commencement_date, *PARAM_CONVERSION.keys)
            .transform_keys do |key|
        PARAM_CONVERSION.keys.include?(key) ? PARAM_CONVERSION[key] : key
      end
    end

    def defer_context?
      params[:context] == "defer"
    end
  end
end
