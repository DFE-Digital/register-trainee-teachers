module Trainees
  class DegreesController < ApplicationController
    def new
      @degree = trainee.degrees.build(locale_code: params[:locale_code])
    end

    def edit
      @degree = trainee.degrees.find(params[:id])
    end

    def create
      @degree = trainee.degrees.build(degree_params.merge(locale_code_params))
      if @degree.save(context: @degree.locale_code.to_sym)
        redirect_to trainee_path(@trainee)
      else
        render :new
      end
    end

    def update
      @degree = trainee.degrees.find(params[:id])
      @degree.assign_attributes(degree_params)
      if @degree.save(context: @degree.locale_code.to_sym)
        redirect_to trainee
      else
        render :edit
      end
    end

  private

    def locale_code_params
      params.require(:degree).permit(:locale_code) if params.dig(:degree, :locale_code).present?
    end

    def degree_params
      params.require(:degree).permit(:uk_degree, :non_uk_degree, :degree_subject, :institution,
                                     :graduation_year, :degree_grade, :country)
    end

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end
  end
end
