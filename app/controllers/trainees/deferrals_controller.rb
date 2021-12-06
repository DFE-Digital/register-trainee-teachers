# frozen_string_literal: true

module Trainees
  class DeferralsController < BaseController
    before_action :redirect_to_confirm_deferral, if: -> { trainee.starts_course_in_the_future? }

    def show
      @deferral_form = DeferralForm.new(trainee)
      redirect_to_start_date_selection unless @deferral_form.itt_start_date.is_a?(Date)
    end

    def update
      authorize(trainee, :defer?)

      @deferral_form = DeferralForm.new(trainee, params: trainee_params, user: current_user)

      if @deferral_form.stash
        redirect_to_confirm_deferral
      else
        render(:show)
      end
    end

  private

    def trainee_params
      params.require(:deferral_form)
        .permit(:date_string, *MultiDateForm::PARAM_CONVERSION.keys)
        .transform_keys do |key|
          MultiDateForm::PARAM_CONVERSION.fetch(key, key)
        end
    end

    def redirect_to_confirm_deferral
      redirect_to(trainee_confirm_deferral_path(trainee))
    end

    def redirect_to_start_date_selection
      redirect_to(trainee_start_date_verification_path(trainee, context: :defer))
    end
  end
end
