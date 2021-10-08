# frozen_string_literal: true

module Trainees
  class TrainingDetailsController < BaseController
    PARAM_CONVERSION = {
      "commencement_date(3i)" => "day",
      "commencement_date(2i)" => "month",
      "commencement_date(1i)" => "year",
    }.freeze

    def edit
      @training_details_form = TrainingDetailsForm.new(trainee)
    end

    def update
      @training_details_form = TrainingDetailsForm.new(trainee, params: trainee_params, user: current_user)

      if @training_details_form.save
        redirect_to(trainee_training_details_confirm_path(trainee))
      else
        render(:edit)
      end
    end

  private

    def trainee_params
      params.require(:training_details_form).permit(:trainee_id, :commencement_date, :commencement_date_radio_option, *PARAM_CONVERSION.keys)
            .transform_keys do |key|
        PARAM_CONVERSION.keys.include?(key) ? PARAM_CONVERSION[key] : key
      end
    end
  end
end
