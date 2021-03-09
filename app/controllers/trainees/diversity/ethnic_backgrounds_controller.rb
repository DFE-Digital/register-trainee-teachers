# frozen_string_literal: true

module Trainees
  module Diversity
    class EthnicBackgroundsController < ApplicationController
      def edit
        authorize trainee
        @ethnic_background = Diversities::EthnicBackgroundForm.new(trainee: trainee)
      end

      def update
        authorize trainee

        @ethnic_background = Diversities::EthnicBackgroundForm.new(trainee: trainee)
        @ethnic_background.assign_attributes(ethnic_background_params)

        if @ethnic_background.save
          redirect_to(origin_page_or_next_step)
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

      def origin_page_or_next_step
        return page_tracker.last_origin_page_path if page_tracker.last_origin_page_path&.include?("diversity/confirm")

        edit_trainee_diversity_disability_disclosure_path(trainee)
      end
    end
  end
end
