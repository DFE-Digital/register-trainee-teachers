# frozen_string_literal: true

module Trainees
  class ConfirmDeleteController < ApplicationController
    before_action :ensure_trainee_is_draft!
    before_action :authorize_trainee

    def show
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
