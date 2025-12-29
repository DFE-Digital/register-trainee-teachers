# frozen_string_literal: true

module Trainees
  class DeferralsController < BaseController
    before_action :redirect_to_defer_reason, if: -> { trainee.starts_course_in_the_future? }

    def show
      @deferral_form = DeferralForm.new(trainee)
      redirect_to_start_date_selection unless @deferral_form.itt_start_date.is_a?(Date)
    end

    def update
      @deferral_form = DeferralForm.new(trainee, params: trainee_params, user: current_user)

      if @deferral_form.stash
        redirect_after_update
      else
        render(:show)
      end
    end

  private

    def trainee_params
      params
        .expect(deferral_form: [:date_string, *MultiDateForm::PARAM_CONVERSION.keys])
        .transform_keys do |key|
          MultiDateForm::PARAM_CONVERSION.fetch(key, key)
        end
    end

    def redirect_after_update
      @deferral_form.defer_reason.present? ? redirect_to_confirm_deferral : redirect_to_defer_reason
    end

    def redirect_to_confirm_deferral
      redirect_to(trainee_confirm_deferral_path(trainee))
    end

    def redirect_to_defer_reason
      redirect_to(trainee_deferral_reason_path(trainee))
    end

    def redirect_to_start_date_selection
      redirect_to(trainee_start_date_verification_path(trainee, context: :defer))
    end

    def authorize_trainee
      authorize(trainee, :defer?)
    end
  end
end
