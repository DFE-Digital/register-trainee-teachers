# frozen_string_literal: true

module Trainees
  module Diversity
    class DisabilityDetailsController < ApplicationController
      before_action :authorize_trainee
      before_action :load_disabilities

      def edit
        @disability_detail_form = Diversities::DisabilityDetailForm.new(trainee)
      end

      def update
        @disability_detail_form = Diversities::DisabilityDetailForm.new(
          trainee,
          params: disability_detail_params,
          user: current_user,
        )

        save_strategy = trainee.draft? ? :save! : :stash

        if @disability_detail_form.public_send(save_strategy)
          redirect_to(trainee_diversity_confirm_path(trainee))
        else
          render(:edit)
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def load_disabilities
        @disabilities = Disability.all
      end

      def disability_detail_params
        return { disability_ids: nil } if params[:diversities_disability_detail_form].blank?

        params.require(:diversities_disability_detail_form).permit(:additional_disability, disability_ids: [])
      end

      def authorize_trainee
        authorize(trainee)
      end
    end
  end
end
