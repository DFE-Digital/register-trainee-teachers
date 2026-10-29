# frozen_string_literal: true

module Trainees
  module Funding
    class FundingEligibilitiesController < BaseController
      include FundingPrerequisitesCheckable

      before_action { require_feature_flag(:funding_eligibility_step) }

      def edit
        @funding_manager = FundingManager.new(trainee)
        @funding_eligibility_form = ::Funding::EligibilityForm.new(trainee)
      end

      def update
        @funding_manager = FundingManager.new(trainee)

        # Routes and subjects with no funding, and years whose funding hasn't been
        # signed off, aren't asked the question; the screen just moves the journey on.
        if @funding_manager.eligibility_informational?
          redirect_to(edit_trainee_funding_training_initiative_path(trainee))
          return
        end

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
