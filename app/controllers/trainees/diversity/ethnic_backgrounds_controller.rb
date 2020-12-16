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
        updater = Diversities::EthnicBackgrounds::Update.call(trainee: trainee, attributes: ethnic_background_param)

        if updater.successful?
          redirect_to(edit_trainee_diversity_disability_disclosure_path(trainee))
        else
          @ethnic_background = updater.ethnic_background
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.find(params[:trainee_id])
      end

      def ethnic_background_param
        return { ethnic_background: nil } if params[:diversities_ethnic_background_form].blank?

        params.require(:diversities_ethnic_background_form).permit(
          *Diversities::EthnicBackgroundForm::FIELDS,
        )
      end
    end
  end
end
