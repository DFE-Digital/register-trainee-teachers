# frozen_string_literal: true

module Trainees
  class TrainingDetailsController < ApplicationController
    def edit
      @trainee = Trainee.find(params[:id])
    end
  end
end
