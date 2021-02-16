# frozen_string_literal: true

module Trainees
  class StartDatesController < ApplicationController
    before_action :authorize_trainee

    PARAM_CONVERSION = {
      "commencement_date(3i)" => "day",
      "commencement_date(2i)" => "month",
      "commencement_date(1i)" => "year",
    }.freeze

    def edit
      @training_details = TrainingDetailsForm.new(trainee)
    end

    def update
      @training_details = TrainingDetailsForm.new(trainee, validate_trainee_id: false)
      @training_details.assign_attributes(trainee_params)

      if @training_details.save
        redirect_to trainee_start_date_confirm_path(trainee)
      else
        render :edit
      end
    end

    def confirm
      page_tracker.save_as_origin!
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def trainee_params
      params.require(:training_details_form).permit(:commencement_date, *PARAM_CONVERSION.keys)
            .transform_keys do |key|
        PARAM_CONVERSION.keys.include?(key) ? PARAM_CONVERSION[key] : key
      end
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
