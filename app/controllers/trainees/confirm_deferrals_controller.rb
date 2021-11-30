# frozen_string_literal: true

module Trainees
  class ConfirmDeferralsController < BaseController
    def show
      page_tracker.save_as_origin!
      deferral_form
    end

    def update
      if deferral_form.save!
        trainee.defer!

        Dttp::DeferJob.perform_later(trainee)

        flash[:success] = "Trainee deferred"
        redirect_to(trainee_path(trainee))
      end
    end

  private

    def deferral_form
      @deferral_form ||= DeferralForm.new(trainee)
    end

    def authorize_trainee
      authorize(trainee, :defer?)
    end
  end
end
