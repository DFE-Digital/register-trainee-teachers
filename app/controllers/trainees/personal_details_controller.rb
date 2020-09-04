module Trainees
  class PersonalDetailsController < ApplicationController
    def edit
      @trainee = Trainee.find(params[:id])
    end
  end
end
