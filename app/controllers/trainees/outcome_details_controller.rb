# frozen_string_literal: true

module Trainees
  class OutcomeDetailsController < ApplicationController
    def confirm
      authorize trainee
    end

    def recommended
      authorize trainee
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end
  end
end
