# frozen_string_literal: true

module Trainees
  module Diversity
    class DisabilityDetailsController < BaseController
      before_action :load_disabilities

      def edit
        @disability_detail_form = Diversities::DisabilityDetailForm.new(trainee)
      end

      def update
        @disability_detail_form = Diversities::DisabilityDetailForm.new(
          trainee,
          params: disability_detail_params,
          user: current_user,
        )

        if @disability_detail_form.stash_or_save!
          redirect_to(trainee_diversity_confirm_path(trainee))
        else
          render(:edit)
        end
      end

    private

      def load_disabilities
        @disabilities = Disability.all
      end

      def disability_detail_params
        return { disability_ids: nil } if params[:diversities_disability_detail_form].blank?

        params.expect(diversities_disability_detail_form: [:additional_disability, { disability_ids: [] }])
      end
    end
  end
end
