# frozen_string_literal: true

module Trainees
  class PersonalDetailsController < BaseController
    include Appliable

    before_action :load_all_nationalities
    before_action :ensure_trainee_is_not_draft!, :load_missing_data_view, only: :show

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
      render(layout: "trainee_record")
    end

    def edit
      @personal_detail_form = PersonalDetailsForm.new(trainee)
    end

    def update
      @personal_detail_form = PersonalDetailsForm.new(trainee, params: personal_details_params, user: current_user)

      if @personal_detail_form.stash_or_save!
        redirect_to(relevant_redirect_path)
      else
        render(:edit)
      end
    end

  private

    def load_missing_data_view
      @missing_data_view = MissingDataBannerView.new(
        Submissions::MissingDataValidator.new(trainee: trainee).missing_fields, trainee
      )
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
        nationality_names: [],
      ).transform_keys do |key|
        DOB_CONVERSION.keys.include?(key) ? DOB_CONVERSION[key] : key
      end
    end

    def relevant_redirect_path
      draft_apply_application? ? page_tracker.last_origin_page_path : trainee_personal_details_confirm_path(trainee)
    end
  end
end
