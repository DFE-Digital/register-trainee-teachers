# frozen_string_literal: true

module Trainees
  class PersonalDetailsController < ApplicationController
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
      trainee.assign_attributes(personal_details_params)
      personal_detail = PersonalDetail.new(trainee)

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
        nationality_ids: [],
      )
    end
  end
end
