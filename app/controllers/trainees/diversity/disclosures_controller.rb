# frozen_string_literal: true

module Trainees
  module Diversity
    class DisclosuresController < ApplicationController
      def edit
        authorize trainee
        @disclosure = Diversities::DisclosureForm.new(trainee: trainee)
      end

      def update
        authorize trainee
        updater = Diversities::Disclosures::Update.call(trainee: trainee, attributes: disclosure_param)

        if updater.successful?
          redirect_to_relevant_step
        else
          @disclosure = updater.disclosure
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def disclosure_param
        return { diversity_disclosure: nil } if params[:diversities_disclosure_form].blank?

        params.require(:diversities_disclosure_form).permit(*Diversities::DisclosureForm::FIELDS)
      end

      def redirect_to_relevant_step
        if trainee.diversity_disclosed?
          redirect_to(edit_trainee_diversity_ethnic_group_path(trainee))
        else
          redirect_to(trainee_diversity_confirm_path(trainee))
        end
      end
    end
  end
end
