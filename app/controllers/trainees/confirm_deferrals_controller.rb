# frozen_string_literal: true

module Trainees
  class ConfirmDeferralsController < ApplicationController
    before_action :authorize_trainee

    def show
      page_tracker.save_as_origin!
      deferral
    end

    def update
      if deferral.save!
        trainee.defer!

        DeferJob.perform_later(trainee.id)

        flash[:success] = "Trainee deferred"
        redirect_to trainee_path(trainee)
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def deferral
      @deferral ||= DeferralForm.new(trainee)
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
