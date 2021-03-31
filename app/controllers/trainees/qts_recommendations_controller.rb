# frozen_string_literal: true

module Trainees
  class QtsRecommendationsController < ApplicationController
    before_action :authorize_trainee

    def create
      if OutcomeDateForm.new(trainee).save!
        trainee.recommend_for_qts!

        RecommendForQtsJob.perform_later(trainee)
        RetrieveQtsJob.set(wait: RetrieveQtsJob::POLL_DELAY).perform_later(trainee)

        redirect_to recommended_trainee_outcome_details_path(trainee)
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee, :recommend_for_qts?)
    end
  end
end
