# frozen_string_literal: true

module Trainees
  class ConfirmPublishCourseController < ApplicationController
    before_action :authorize_trainee

    def edit
      render body: "ye olde confirm page"
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
