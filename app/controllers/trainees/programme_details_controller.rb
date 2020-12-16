# frozen_string_literal: true

module Trainees
  class ProgrammeDetailsController < ApplicationController
    PROGRAMME_DATE_CONVERSION = {
      "programme_start_date(3i)" => "start_day",
      "programme_start_date(2i)" => "start_month",
      "programme_start_date(1i)" => "start_year",
      "programme_end_date(3i)" => "end_day",
      "programme_end_date(2i)" => "end_month",
      "programme_end_date(1i)" => "end_year",
    }.freeze

    PROGRAMME_DETAILS_PARAMS_KEYS = %i[subject
                                       main_age_range
                                       additional_age_range].freeze

    def edit
      authorize trainee
      @programme_detail = ProgrammeDetailForm.new(trainee)
    end

    def update
      authorize trainee
      updater = ProgrammeDetails::Update.call(trainee: trainee,
                                              attributes: programme_details_params)
      if updater.successful?
        redirect_to trainee_programme_details_confirm_path(trainee)
      else
        @programme_detail = updater.programme_detail
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end

    def programme_details_params
      params.require(:programme_detail_form).permit(
        *PROGRAMME_DETAILS_PARAMS_KEYS,
      ).except(*PROGRAMME_DATE_CONVERSION.keys)
      .merge(programme_date_params)
    end

    def programme_date_params
      params.require(:programme_detail_form).except(
        *PROGRAMME_DETAILS_PARAMS_KEYS,
      ).permit(*PROGRAMME_DATE_CONVERSION.keys)
      .transform_keys { |key| PROGRAMME_DATE_CONVERSION[key] }
    end

    def redirect_to_confirm
      redirect_to(trainee_programme_details_confirm_path(trainee))
    end
  end
end
