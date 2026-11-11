# frozen_string_literal: true

module Trainees
  module Funding
    class BursariesController < BaseController
      include FundingPrerequisitesCheckable

      before_action :funding_method_applicable

      def edit
        funding_manager
        @bursary_form = form.new(trainee)
      end

      def update
        funding_manager
        @bursary_form = form.new(trainee, params: form_params)

        if @bursary_form.stash_or_save!
          redirect_to(trainee_funding_confirm_path)
        else
          render(:edit)
        end
      end

    private

      # With the eligibility step, there's nothing to choose when the trainee
      # isn't eligible, the year's funding isn't signed off, or there's no
      # funding for the route and subject (for example no EYTDA amounts yet).
      def funding_method_applicable
        return unless FeatureService.enabled?(:funding_eligibility_step)
        return if funding_manager.funding_open? && !funding_manager.no_funding?

        redirect_to(trainee_funding_confirm_path(trainee))
      end

      def form_params
        if params.key?(:funding_grant_and_tiered_bursary_form)
          params.expect(
            funding_grant_and_tiered_bursary_form: %i[custom_applying_for_grant
                                                      custom_bursary_tier],
          )
        else
          bursary_params
        end
      end

      def bursary_params
        return { applying_for_bursary: nil } if params[:funding_bursary_form].blank?

        params.expect(
          funding_bursary_form: [:funding_type],
        )
      end

      def form
        funding_manager.applicable_available_funding == :grant_and_tiered_bursary ? ::Funding::GrantAndTieredBursaryForm : ::Funding::BursaryForm
      end

      def funding_manager
        @funding_manager ||= if FeatureService.enabled?(:funding_eligibility_step)
                               FundingManager.new(trainee, funding_eligibility: ::Funding::EligibilityForm.new(trainee).funding_eligibility)
                             else
                               FundingManager.new(trainee)
                             end
      end
    end
  end
end
