# frozen_string_literal: true

module Trainees
  class DegreesController < ApplicationController
    before_action :authorize_trainee
    before_action :set_degrees_form

    def new
      @degree_form = @degrees_form.build_degree(locale_code: params[:locale_code])
    end

    def create
      @degree_form = @degrees_form.build_degree(degree_params)

      if @degree_form.save_or_stash
        redirect_to trainee_degrees_confirm_path(trainee)
      else
        render :new
      end
    end

    def edit
      @degree_form = @degrees_form.find_degree_from_param(params[:id])
    end

    def update
      @degree_form = @degrees_form.find_degree_from_param(params[:id])
      @degree_form.attributes = degree_params

      if @degree_form.save_or_stash
        redirect_to trainee_degrees_confirm_path(trainee)
      else
        render :edit
      end
    end

    def destroy
      @degree_form = @degrees_form.find_degree_from_param(params[:id])

      @degree_form.destroy!

      flash[:success] = "Trainee degree deleted"

      redirect_to page_tracker.last_origin_page_path
    end

  private

    def degree_params
      params.require(:degree).permit(DegreeForm::FIELDS.excluding(:slug))
    end

    def authorize_trainee
      authorize(trainee)
    end

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def set_degrees_form
      @degrees_form = DegreesForm.new(trainee)
    end
  end
end
