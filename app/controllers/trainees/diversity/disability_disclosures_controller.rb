# frozen_string_literal: true

module Trainees
  module Diversity
    class DisabilityDisclosuresController < ApplicationController
      before_action :authorize_trainee

      def edit
        @disability_disclosure_form = Diversities::DisabilityDisclosureForm.new(trainee)
      end

      def update
        @disability_disclosure_form = Diversities::DisabilityDisclosureForm.new(
          trainee,
          params: disability_disclosure_params,
          user: current_user,
        )

        save_strategy = trainee.draft? ? :save! : :stash

        if @disability_disclosure_form.public_send(save_strategy)
          redirect_to_relevant_step
        else
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def disability_disclosure_params
        return { disability_disclosure: nil } if params[:diversities_disability_disclosure_form].blank?

        params.require(:diversities_disability_disclosure_form).permit(*Diversities::DisabilityDisclosureForm::FIELDS)
      end

      def redirect_to_relevant_step
        if @disability_disclosure_form.disability_not_provided? || @disability_disclosure_form.no_disability?
          redirect_to(trainee.apply_application? ? page_tracker.last_origin_page_path : trainee_diversity_confirm_path(trainee))
        else
          redirect_to(edit_trainee_diversity_disability_detail_path(trainee))
        end
      end

      def authorize_trainee
        authorize(trainee)
      end
    end
  end
end
