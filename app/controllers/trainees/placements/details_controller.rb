# frozen_string_literal: true

module Trainees
  module Placements
    class DetailsController < BaseController
      def edit
        @placement_detail_form = PlacementDetailForm.new(trainee)
      end

      def update
        @placement_detail_form = PlacementDetailForm.new(trainee, params: placement_detail_params, user: current_user)

        if @placement_detail_form.stash_or_save!
          redirect_to(next_step)
        else
          render(:edit)
        end
      end

    private

      def placement_detail_params
        return { placement_detail: nil } if params[:placement_detail_form].blank?

        params.expect(placement_detail_form: PlacementDetailForm::FIELDS)
      end

      def next_step
        if @placement_detail_form.detail_provided?
          new_trainee_placement_path(trainee)
        elsif @placement_detail_form.detail_not_provided?
          trainee_path(trainee)
        else
          trainee_placements_confirm_path(trainee)
        end
      end
    end
  end
end
