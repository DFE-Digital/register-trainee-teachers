module Trainees
  class DegreesController < ApplicationController
    def new
      @degree = trainee.degrees.build
    end

    def create
      @degree = trainee.degrees.build(degree_params)
      if @degree.save
        redirect_to trainee
      else
        render :new
      end
    end

  private

    def degree_params
      params.require(:degree).permit(:locale_code, :uk_degree, :non_uk_degree)
    end

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end
  end
end
