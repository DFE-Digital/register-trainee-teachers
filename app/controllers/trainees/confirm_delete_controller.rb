# frozen_string_literal: true

module Trainees
  class ConfirmDeleteController < ApplicationController
    before_action :ensure_trainee_is_draft!

    def show
      authorize trainee
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end
  end
end
