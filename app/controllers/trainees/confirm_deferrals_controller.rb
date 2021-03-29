# frozen_string_literal: true

module Trainees
  class ConfirmDeferralsController < ApplicationController
    before_action :authorize_trainee

    def show
      page_tracker.save_as_origin!
      deferral_form
    end

    def update
      if deferral_form.save!
        trainee.defer!

        DeferJob.perform_later(trainee)

        flash[:success] = "Trainee deferred"
        redirect_to trainee_path(trainee)
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def deferral_form
      @deferral_form ||= DeferralForm.new(trainee)
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
