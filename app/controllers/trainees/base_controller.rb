# frozen_string_literal: true

module Trainees
  class BaseController < ApplicationController
    before_action :authorize_trainee

  private

    def trainee
      if Trainee.where(slug: params[:trainee_id]).blank?
        raise(
          "Trainee for params #{params} not found. Available slugs are: #{Trainee.pluck(:slug).join(' ')}",
        )
      end

      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee)
    end

    def training_route
      TrainingRoutesForm.new(trainee).training_route
    end
  end
end
