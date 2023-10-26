# frozen_string_literal: true

module Trainees
  class PlacementsController < BaseController
    before_action { require_feature_flag(:trainee_placement) }

    def new
      @trainee = trainee
      @placement_form = PlacementForm.new(
        placements_form: PlacementsForm.new(@trainee),
        placement: Placement.new,
      )
    end

    def create
      @trainee = trainee
      @placement_form = PlacementForm.new(
        placements_form: PlacementsForm.new(@trainee),
        placement: Placement.new(new_placement_params),
      )

      if @placement_form.save_or_stash
        redirect_to(trainee_placements_confirm_path(trainee_id: @trainee.slug))
      else
        render(:new)
      end
    end

    def confirm_destroy
      @placement_form = DestroyPlacementForm.find_from_param(@trainee, params[:id])
    end

    def destroy
      @placement_form = DestroyPlacementForm.find_from_param(@trainee, params[:id])
      @placement_form.destroy!

      flash[:success] = I18n.t("flash.trainee_placement_deleted")

      redirect_to(trainee_path(trainee))
    end

  private

    def new_placement_params
      params.fetch(:placement, {}).permit(:school_id, :urn, :name, :address, :postcode)
    end
  end
end
