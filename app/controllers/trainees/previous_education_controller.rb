module Trainees
  class PreviousEducationController < ApplicationController
    def edit
      @trainee = Trainee.find(params[:id])
    end
  end
end
