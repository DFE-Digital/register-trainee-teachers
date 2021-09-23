# frozen_string_literal: true

module Trainees
  module Diversity
    class EthnicBackgroundsController < ApplicationController
      before_action :authorize_trainee

      def edit
        @ethnic_background_form = Diversities::EthnicBackgroundForm.new(trainee)
      end

      def update
        @ethnic_background_form = Diversities::EthnicBackgroundForm.new(
          trainee,
          params: ethnic_background_params,
          user: current_user,
        )

        if @ethnic_background_form.stash_or_save!
          redirect_to relevant_path
        else
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def ethnic_background_params
        return { ethnic_background: nil } if params[:diversities_ethnic_background_form].blank?

        required_params = params.require(:diversities_ethnic_background_form).permit(
          *Diversities::EthnicBackgroundForm::FIELDS,
        )

        required_params[:additional_ethnic_background] = nil if background_is_different?(required_params)
        required_params
      end

      def background_is_different?(required_params)
        trainee.ethnic_background.present? && trainee.ethnic_background != required_params[:ethnic_background]
      end

      def relevant_path
        if trainee.disability_disclosure.present?
          trainee_diversity_confirm_path(trainee)
        else
          edit_trainee_diversity_disability_disclosure_path(trainee)
        end
      end

      def authorize_trainee
        authorize(trainee)
      end
    end
  end
end
