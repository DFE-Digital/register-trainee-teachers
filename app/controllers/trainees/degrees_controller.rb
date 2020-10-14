module Trainees
  class DegreesController < ApplicationController
    def new
      @degree = trainee.degrees.build
    end

    def edit
      @degree = trainee.degrees.find(params[:id])
    end

    def create
      @degree = trainee.degrees.build(degree_params)
      if @degree.save
        if @degree.uk?
          redirect_to edit_trainee_degree_path(@trainee, @degree)
        else
          redirect_to trainee
        end
      else
        render :new
      end
    end

    def update
      @degree = trainee.degrees.find(params[:id])
      if @degree.update(uk_degree_details_params)
        redirect_to trainee
      else
        render :edit
      end
    end

  private

    def degree_params
      params.require(:degree).permit(:locale_code, :uk_degree, :non_uk_degree)
    end

    def uk_degree_details_params
      params.require(:degree).permit(:degree_subject, :institution, :graduation, :degree_grade)
    end

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end
  end
end
