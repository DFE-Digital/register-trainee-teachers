module Trainees
  class PersonalDetailsController < ApplicationController
    def index
      @trainee = Trainee.find(params[:id])
    end
  end
end
