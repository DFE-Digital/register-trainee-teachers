# frozen_string_literal: true

module Trainees
  class TrainingDetailsController < ApplicationController
    before_action :authorize_trainee

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
        redirect_to relevant_redirect_path
      else
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def trainee_params
      params.require(:training_details_form).permit(:trainee_id, :commencement_date, :commencement_date_radio_option, *PARAM_CONVERSION.keys)
            .transform_keys do |key|
        PARAM_CONVERSION.keys.include?(key) ? PARAM_CONVERSION[key] : key
      end
    end

    def authorize_trainee
      authorize(trainee)
    end

    def relevant_redirect_path
      trainee.apply_application? ? page_tracker.last_origin_page_path : trainee_training_details_confirm_path(trainee)
    end
  end
end
