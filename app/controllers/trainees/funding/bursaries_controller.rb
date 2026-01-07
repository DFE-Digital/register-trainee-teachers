# frozen_string_literal: true

module Trainees
  module Funding
    class BursariesController < BaseController
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
        @funding_manager ||= FundingManager.new(trainee)
      end
    end
  end
end
