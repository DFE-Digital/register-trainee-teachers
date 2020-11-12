# frozen_string_literal: true

module Trainees
  class TrainingDetailsController < ApplicationController
    def edit
      authorize trainee
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:id])
    end
  end
end
