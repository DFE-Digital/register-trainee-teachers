# frozen_string_literal: true

module Trainees
  class AwardRecommendationsController < BaseController
    def create
      if OutcomeDateForm.new(trainee, update_trs: false).save! && trainee.submission_ready?
        trainee.recommend_for_award!

        Trainees::UpdateIttDataInTra.call(trainee:)

        flash[:success] = I18n.t("flash.trainee_status_updated", award_type: trainee.award_type)
        redirect_to(trainee_path(trainee))
      end
    end

  private

    def authorize_trainee
      authorize(trainee, :recommend_for_award?)
    end
  end
end
