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
      @training_details = TraineeStartDateForm.new(trainee)
    end

    def update
      @training_details = TraineeStartDateForm.new(trainee, trainee_params)

      save_strategy = trainee.draft? ? :save! : :stash

      if @training_details.public_send(save_strategy)
        redirect_to trainee_start_date_confirm_path(trainee)
      else
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def trainee_params
      params.require(:trainee_start_date_form).permit(:commencement_date, *PARAM_CONVERSION.keys)
            .transform_keys do |key|
        PARAM_CONVERSION.keys.include?(key) ? PARAM_CONVERSION[key] : key
      end
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
