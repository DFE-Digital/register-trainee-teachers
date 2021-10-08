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

        if @disability_disclosure_form.stash_or_save!
          redirect_to(relevant_path)
        else
          render(:edit)
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

      def relevant_path
        if @disability_disclosure_form.disability_not_provided? || @disability_disclosure_form.no_disability?
          trainee_diversity_confirm_path(trainee)
        else
          edit_trainee_diversity_disability_detail_path(trainee)
        end
      end

      def authorize_trainee
        authorize(trainee)
      end
    end
  end
end
