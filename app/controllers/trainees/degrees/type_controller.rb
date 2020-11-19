# frozen_string_literal: true

module Trainees
  module Degrees
    class TypeController < ApplicationController
      def new
        authorize trainee
        @degree = trainee.degrees.build
      end

      def create
        authorize trainee
        @degree = trainee.degrees.build(locale_code_params)
        if @degree.valid?
          redirect_to new_trainee_degree_path(trainee_id: params[:trainee_id], **locale_code_params)
        else
          render :new
        end
      end

    private

      def locale_code_params
        params.require(:degree).permit(:locale_code) if params.dig(:degree, :locale_code).present?
      end

      def trainee
        @trainee ||= Trainee.find(params[:trainee_id])
      end
    end
  end
end
