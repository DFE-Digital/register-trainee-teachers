# frozen_string_literal: true

module Trainees
  module Degrees
    class TypeController < BaseController
      def new
        @degree = trainee.degrees.build(locale_code_params)
      end

      def create
        @degree = trainee.degrees.build(locale_code_params)

        if @degree.valid?
          redirect_to(new_trainee_degree_path(trainee_id: params[:trainee_id], **locale_code_params))
        else
          render(:new)
        end
      end

    private

      def authorize_trainee
        authorize([:degrees, trainee])
      end

      def locale_code_params
        params.expect(degree: [:locale_code]) if params.dig(:degree, :locale_code).present?
      end
    end
  end
end
