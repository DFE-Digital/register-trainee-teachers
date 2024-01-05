# frozen_string_literal: true

module Trainees
  class PlacementsController < BaseController
    include Appliable
    include TraineeHelper

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

      if @placement_form.still_searching?
        redirect_to(
          search_trainee_placements_path(
            trainee_id: @trainee.slug,
            school_search: @placement_form.school_search,
          ),
        )
      elsif @placement_form.save_or_stash
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

      flash[:success] = I18n.t("flash.trainee_placement_removed")

      redirect_to(trainee_placements_confirm_path(trainee_id: @trainee.slug))
    end

    def search
      @select_placement_school_form = SelectPlacementSchoolForm.new(
        trainee: trainee,
        query: params[:school_search],
      )
    end

  private

    def authorize_trainee
      policy(trainee).write_placements?
    end

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
      if params[:placement].present?
        params.fetch(:placement, {}).permit(:school_id, :school_search, :urn, :name, :address, :postcode)
      elsif params[:select_placement_school_form].present?
        params.fetch(:select_placement_school_form, {}).permit(:school_id)
      end
    end
  end
end
