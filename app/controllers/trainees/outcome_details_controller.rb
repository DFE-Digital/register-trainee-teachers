# frozen_string_literal: true

module Trainees
  class OutcomeDetailsController < ApplicationController
    before_action :authorize_trainee

    def confirm
      @outcome_form = OutcomeDateForm.new(trainee)
    end

    def recommended
      ensure_trainee_is_not_draft!
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
