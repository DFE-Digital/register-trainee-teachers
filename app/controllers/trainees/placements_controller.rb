# frozen_string_literal: true

module Trainees
  class PlacementsController < BaseController
    include Appliable

    before_action { require_feature_flag(:trainee_placement) }

    def new
      @placement_form = PlacementForm.new(
        placements_form: placements_form,
        placement: Placement.new,
      )
    end

    def edit
      placement_form
    end

    def create
      @placement_form = PlacementForm.new(
        placements_form: placements_form,
        placement: Placement.new(placement_params),
      )

      if @placement_form.save_or_stash
        redirect_to(trainee_placements_confirm_path(trainee_id: @trainee.slug))
      else
        render(:new)
      end
    end

    def delete
      @placements_form = PlacementsForm.new(@trainee)
      @placement_form = DestroyPlacementForm.find_from_param(
        placements_form: @placements_form,
        slug: params[:id],
      )
    end

    def update
      placement_form.update_placement(placement_params)

      if placement_form.save_or_stash
        redirect_to(relevant_redirect_path)
      else
        render(:edit)
      end
    end

    def destroy
      @placement_form = DestroyPlacementForm.find_from_param(
        placements_form: PlacementsForm.new(@trainee),
        slug: params[:id],
      )
      @placement_form.destroy_or_stash!

      flash[:success] = "Placement removed"

      redirect_to(trainee_placements_confirm_path(trainee_id: @trainee.slug))
    end

  private

    def relevant_redirect_path
      draft_apply_application? ? page_tracker.last_origin_page_path : trainee_placements_confirm_path(trainee)
    end

    def placements_form
      @placements_form ||= PlacementsForm.new(trainee)
    end

    def placement_form
      @placement_form ||= placements_form.find_placement_from_param(params[:id])
    end

    def placement_params
      params.fetch(:placement, {}).permit(:school_id, :urn, :name, :address, :postcode)
    end
  end
end
