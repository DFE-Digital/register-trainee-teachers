# frozen_string_literal: true

module Trainees
  class ReviewDraftController < ApplicationController
    include Breadcrumbable

    before_action :ensure_trainee_is_draft!

    def show
      authorize trainee
      save_origin_page_for(trainee)
      @pre_submission_checker = Trns::SubmissionChecker.call(trainee: trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:id])
    end
  end
end
