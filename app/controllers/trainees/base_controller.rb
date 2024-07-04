# frozen_string_literal: true

module Trainees
  class BaseController < ApplicationController
    before_action :authorize_trainee

    helper_method :missing_fields

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee)
    end

    def training_route
      TrainingRoutesForm.new(trainee).training_route
    end

    def missing_fields
      @missing_fields ||= Submissions::MissingDataValidator.new(trainee:).missing_fields
    end
  end
end
