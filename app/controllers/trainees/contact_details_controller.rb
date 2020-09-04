module Trainees
  class ContactDetailsController < ApplicationController
    def edit
      @trainee = Trainee.find(params[:id])
    end
  end
end
