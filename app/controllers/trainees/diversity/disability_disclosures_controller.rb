# frozen_string_literal: true

module Trainees
  module Diversity
    class DisabilityDisclosuresController < BaseController
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

      def disability_disclosure_params
        return { disability_disclosure: nil } if params[:diversities_disability_disclosure_form].blank?

        params.expect(diversities_disability_disclosure_form: [*Diversities::DisabilityDisclosureForm::FIELDS])
      end

      def relevant_path
        if @disability_disclosure_form.disability_not_provided? || @disability_disclosure_form.no_disability?
          trainee_diversity_confirm_path(trainee)
        else
          edit_trainee_diversity_disability_detail_path(trainee)
        end
      end
    end
  end
end
