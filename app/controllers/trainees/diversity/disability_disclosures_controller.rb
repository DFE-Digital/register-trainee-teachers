# frozen_string_literal: true

module Trainees
  module Diversity
    class DisabilityDisclosuresController < ApplicationController
      def edit
        authorize trainee
        @disability_disclosure = Diversities::DisabilityDisclosureForm.new(trainee: trainee)
      end

      def update
        authorize trainee
        updater = Diversities::DisabilityDisclosures::Update.call(
          trainee: trainee,
          attributes: disability_disclosure_params,
        )

        if updater.successful?
          redirect_to_relevant_step
        else
          @disability_disclosure = updater.disability_disclosure
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.find(params[:trainee_id])
      end

      def disability_disclosure_params
        return { disability_disclosure: nil } if params[:diversities_disability_disclosure_form].blank?

        params.require(:diversities_disability_disclosure_form).permit(*Diversities::DisabilityDisclosureForm::FIELDS)
      end

      def redirect_to_relevant_step
        if trainee.disability_not_provided? || trainee.no_disability?
          redirect_to(trainee_diversity_disability_disclosure_confirm_path(trainee))
        else
          redirect_to(edit_trainee_diversity_disability_detail_path(trainee))
        end
      end
    end
  end
end
