# frozen_string_literal: true

module Trainees
  class OutcomeDatesController < ApplicationController
    PARAM_CONVERSION = {
      "outcome_date(3i)" => "day",
      "outcome_date(2i)" => "month",
      "outcome_date(1i)" => "year",
    }.freeze

    def edit
      authorize trainee
      @outcome = OutcomeDate.new(trainee)
    end

    def update
      authorize trainee
      @outcome = OutcomeDate.new(trainee)
      @outcome.assign_attributes(trainee_params)

      if @outcome.save
        redirect_to edit_trainee_path(trainee)
      else
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end

    def trainee_params
      params.require(:outcome_date).permit(:outcome_date_string, *PARAM_CONVERSION.keys)
        .transform_keys do |key|
          PARAM_CONVERSION.keys.include?(key) ? PARAM_CONVERSION[key] : key
        end
    end
  end
end
