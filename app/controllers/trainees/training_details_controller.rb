module Trainees
  class TrainingDetailsController < ApplicationController
    def edit
      @trainee = Trainee.find(params[:id])
    end
  end
end
