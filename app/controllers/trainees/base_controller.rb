# frozen_string_literal: true

module Trainees
  class BaseController < ApplicationController
    before_action :authorize_trainee

  private

    def trainee
      Rails.logger.debug { "Looking for: #{params[:trainee_id]} in #{Trainee.all.map(&:slug)}...\n" }

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
