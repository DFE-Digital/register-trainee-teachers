# frozen_string_literal: true

module Trainees
  class PersonalDetailsController < ApplicationController
    before_action :authorize_trainee
    before_action :load_all_nationalities
    before_action :ensure_trainee_is_not_draft!, only: :show

    DOB_CONVERSION = {
      "date_of_birth(3i)" => "day",
      "date_of_birth(2i)" => "month",
      "date_of_birth(1i)" => "year",
    }.freeze

    NATIONALITIES = [
      Dttp::CodeSets::Nationalities::BRITISH,
      Dttp::CodeSets::Nationalities::IRISH,
    ].freeze

    def show
      page_tracker.save_as_origin!
      clear_form_stash(trainee)
      render layout: "trainee_record"
    end

    def edit
      @personal_detail_form = PersonalDetailsForm.new(trainee)
    end

    def update
      personal_detail = PersonalDetailsForm.new(trainee, params: personal_details_params, user: current_user)
      save_strategy = trainee.draft? ? :save! : :stash

      if personal_detail.public_send(save_strategy)
        redirect_to trainee_personal_details_confirm_path(personal_detail.trainee)
      else
        @personal_detail_form = personal_detail
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def load_all_nationalities
      @nationalities = Nationality.where(name: NATIONALITIES)
      @other_nationalities = Nationality.all
    end

    def personal_details_params
      params.require(:personal_details_form).permit(
        *PersonalDetailsForm::FIELDS,
        *DOB_CONVERSION.keys,
        :other,
        :other_nationality1,
        :other_nationality1_raw,
        :other_nationality2,
        :other_nationality2_raw,
        :other_nationality3,
        :other_nationality3_raw,
        nationality_ids: [],
      ).transform_keys do |key|
        DOB_CONVERSION.keys.include?(key) ? DOB_CONVERSION[key] : key
      end
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
