# frozen_string_literal: true

module Trainees
  class IqtsCountriesController < BaseController
    def edit
      @iqts_country_form = IqtsCountryForm.new(trainee)
    end

    def update
      @iqts_country_form = IqtsCountryForm.new(trainee, params: iqts_countries_params)

      if @iqts_country_form.stash_or_save!
        redirect_to(trainee_iqts_country_confirm_path(trainee))
      else
        render(:edit)
      end
    end

  private

    def iqts_countries_params
      params.expect(iqts_country_form: %i[iqts_country iqts_country_raw])
    end
  end
end
