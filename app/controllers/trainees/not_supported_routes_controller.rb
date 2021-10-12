# frozen_string_literal: true

module Trainees
  class NotSupportedRoutesController < BaseController
    skip_before_action :authorize_trainee

    def index
      find_trainee
      render("trainees/not_supported_route")
    end

  private

    def find_trainee
      return unless params[:trainee_id]

      @trainee = Trainee.from_param(params[:trainee_id])
    end
  end
end
