# frozen_string_literal: true

module Trainees
  class PersonalDetailsController < ApplicationController
    DOB_CONVERSION = {
      "date_of_birth(3i)" => "day",
      "date_of_birth(2i)" => "month",
      "date_of_birth(1i)" => "year",
    }.freeze

    def show
      authorize trainee
      render layout: "trainee_record"
    end

    def edit
      authorize trainee
      nationalities
      @personal_detail = PersonalDetail.new(trainee)
    end

    def update
      authorize trainee
      nationalities
      personal_detail = PersonalDetail.new(trainee, personal_details_params)

      if personal_detail.save
        redirect_to trainee_personal_details_confirm_path(personal_detail.trainee)
      else
        @personal_detail = personal_detail
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end

    def nationalities
      @nationalities ||= Nationality.where(name: %w[british irish other])
    end

    def personal_details_params
      params.require(:personal_detail).permit(
        *PersonalDetail::FIELDS,
        *DOB_CONVERSION.keys,
        nationality_ids: [],
      ).transform_keys do |key|
        DOB_CONVERSION.keys.include?(key) ? DOB_CONVERSION[key] : key
      end
    end
  end
end
