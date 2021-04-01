# frozen_string_literal: true

module Trainees
  module Degrees
    class TypeController < ApplicationController
      before_action :authorize_trainee

      def new
        @degree = trainee.degrees.build
      end

      def create
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
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def authorize_trainee
        authorize(trainee)
      end
    end
  end
end
