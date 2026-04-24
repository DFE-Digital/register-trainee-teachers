# frozen_string_literal: true

module Trainees
  module Funding
    class FundingEligibilitiesController < BaseController
      def edit
        @funding_eligibility_form = ::Funding::EligibilityForm.new(trainee)
      end

      def update
        @funding_eligibility_form = ::Funding::EligibilityForm.new(trainee, params: trainee_params, user: current_user)

        if @funding_eligibility_form.stash_or_save!
          redirect_to(edit_trainee_funding_training_initiative_path(trainee))
        else
          render(:edit)
        end
      end

    private

      def trainee_params
        return { funding_eligibility: nil } if params[:funding_eligibility_form].blank?

        params.expect(funding_eligibility_form: ::Funding::EligibilityForm::FIELDS)
      end
    end
  end
end
