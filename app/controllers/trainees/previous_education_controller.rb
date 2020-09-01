module Trainees
  class PreviousEducationController < ApplicationController
    def index
      @trainee = Trainee.find(params[:id])
    end
  end
end
