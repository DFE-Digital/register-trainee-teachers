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
        redirect_to edit_trainee_degree_path(@trainee, @degree)
      else
        render :new
      end
    end

    def update
      @degree = trainee.degrees.find(params[:id])
      degree_details_params = @degree.uk? ? uk_degree_details_params : non_uk_degree_details_params
      @degree.assign_attributes(degree_details_params)
      if @degree.save(context: @degree.locale_code.to_sym)
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
      params.require(:degree).permit(:degree_subject, :institution, :graduation_year, :degree_grade)
    end

    def non_uk_degree_details_params
      params.require(:degree).permit(:degree_subject, :country, :graduation_year)
    end

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end
  end
end
