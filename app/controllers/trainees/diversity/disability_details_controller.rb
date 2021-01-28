# frozen_string_literal: true

module Trainees
  module Diversity
    class DisabilityDetailsController < ApplicationController
      def edit
        authorize trainee
        disabilities
        @disability_detail = Diversities::DisabilityDetailForm.new(trainee: trainee)
      end

      def update
        authorize trainee
        disabilities

        disability_detail = Diversities::DisabilityDetailForm.new(trainee: trainee, attributes: disability_detail_params)

        if disability_detail.save
          redirect_to(trainee_diversity_confirm_path(trainee))
        else
          @disability_detail = disability_detail
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def disabilities
        @disabilities ||= Disability.all
      end

      def disability_detail_params
        return { disability_ids: nil } if params[:diversities_disability_detail_form].blank?

        params.require(:diversities_disability_detail_form).permit(:additional_disability, disability_ids: [])
      end
    end
  end
end
