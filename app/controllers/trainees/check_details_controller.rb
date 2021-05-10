# frozen_string_literal: true

module Trainees
  class CheckDetailsController < ApplicationController
    before_action :ensure_trainee_is_draft!
    before_action :authorize_trainee

    def show
      page_tracker.save_as_origin!
      @form = TrnSubmissionForm.new(trainee: trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:id])
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
