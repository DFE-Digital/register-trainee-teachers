# frozen_string_literal: true

module Trainees
  class PersonalDetailsController < ApplicationController
    before_action :ensure_trainee_is_not_draft!, only: :show

    DOB_CONVERSION = {
      "date_of_birth(3i)" => "day",
      "date_of_birth(2i)" => "month",
      "date_of_birth(1i)" => "year",
    }.freeze

    NATIONALITIES = %w[british irish].freeze

    def show
      authorize trainee
      page_tracker.save_as_origin!
      render layout: "trainee_record"
    end

    def edit
      authorize trainee
      nationalities
      other_nationalities
      @personal_detail = PersonalDetailForm.new(trainee)
    end

    def update
      authorize trainee
      nationalities
      other_nationalities
      personal_detail = PersonalDetailForm.new(trainee, personal_details_params)

      if personal_detail.save
        redirect_to trainee_personal_details_confirm_path(personal_detail.trainee)
      else
        @personal_detail = personal_detail
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def nationalities
      @nationalities ||= Nationality.where(name: NATIONALITIES)
    end

    def other_nationalities
      @other_nationality ||= Nationality.find_by(name: "other")
      @other_nationalities ||= Nationality.where.not(name: NATIONALITIES)
    end

    def personal_details_params
      params.require(:personal_detail_form).permit(
        *PersonalDetailForm::FIELDS,
        *DOB_CONVERSION.keys,
        :other,
        :other_nationality1,
        :other_nationality2,
        :other_nationality3,
        nationality_ids: [],
      ).transform_keys do |key|
        DOB_CONVERSION.keys.include?(key) ? DOB_CONVERSION[key] : key
      end
    end
  end
end
