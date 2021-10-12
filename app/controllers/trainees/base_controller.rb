# frozen_string_literal: true

module Trainees
  class BaseController < ApplicationController
    before_action :authorize_trainee

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
