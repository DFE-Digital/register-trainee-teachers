module Trainees
  class PersonalDetailsController < ApplicationController
    def edit
      @trainee = Trainee.find(params[:id])
      @nationalities = Nationality.where(name: %w[british irish other])
    end
  end
end
