module Trainees
  class CourseDetailsController < ApplicationController
    def edit
      @trainee = Trainee.find(params[:id])
    end
  end
end
