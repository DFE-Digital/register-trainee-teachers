# frozen_string_literal: true

module Trainees
  class ReviewDraftController < ApplicationController
    def show
      authorize trainee
      @pre_submission_checker = Trns::SubmissionChecker.call(trainee: trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:id])
    end
  end
end
