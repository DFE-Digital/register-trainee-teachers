# frozen_string_literal: true

module Trainees
  class CheckDetailsController < ApplicationController
    before_action :ensure_trainee_is_draft!

    def show
      authorize trainee
      page_tracker.save_as_origin!
      @trn_submission_form = TrnSubmissionForm.new(trainee: trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:id])
    end
  end
end
