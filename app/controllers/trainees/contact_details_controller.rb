module Trainees
  class ContactDetailsController < ApplicationController
    def index
      @trainee = Trainee.find(params[:id])
    end
  end
end
