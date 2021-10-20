# frozen_string_literal: true

module Trainees
  module Funding
    class BursariesController < BaseController
      def edit
        @bursary_form = ::Funding::BursaryForm.new(trainee)
      end

      def update
        @bursary_form = ::Funding::BursaryForm.new(trainee, params: bursary_params)
        if @bursary_form.stash_or_save!
          redirect_to(trainee_funding_confirm_path)
        else
          render(:edit)
        end
      end

    private

      def bursary_params
        return { applying_for_bursary: nil } if params[:funding_bursary_form].blank?

        params.require(:funding_bursary_form).permit(
          :funding_type,
        )
      end
    end
  end
end
