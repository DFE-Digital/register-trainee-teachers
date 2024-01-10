# frozen_string_literal: true

module Trainees
  class PlacementSchoolSearchesController < BaseController
    include Appliable
    include TraineeHelper

    def new
      @select_placement_school_form = SelectPlacementSchoolForm.new(
        trainee: trainee,
        query: params[:school_search],
      )
    end

    def edit
      @select_placement_school_form = SelectPlacementSchoolForm.new(
        trainee: trainee,
        placement_slug: params[:id],
        query: params[:school_search],
      )
    end

    def create
      @select_placement_school_form = SelectPlacementSchoolForm.new(
        trainee: trainee,
        query: placement_params[:school_search],
      )
      @select_placement_school_form.school_id = placement_params[:school_id]
      @placement_form = PlacementForm.new(
        placements_form: placements_form,
        placement: Placement.new(placement_params),
      )

      if @select_placement_school_form.valid?(:create) && @placement_form.save_or_stash
        redirect_to(trainee_placements_confirm_path(trainee_id: @trainee.slug))
      else
        # TODO: `params[:school_search]` is not being passed through to this method
        render(:new)
      end
    end

    def update
      @select_placement_school_form = SelectPlacementSchoolForm.new(
        trainee: trainee,
        placement_slug: params[:id],
        query: placement_params[:school_search],
      )
      @select_placement_school_form.school_id = placement_params[:school_id]

      placement_form.update_placement(placement_params)
      if @select_placement_school_form.valid?(:update) && placement_form.save_or_stash
        redirect_to(relevant_redirect_path)
      else
        render(:edit)
      end
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
        params.fetch(:placement, {}).permit(:school_id, :school_search)
      elsif params[:select_placement_school_form].present?
        params.fetch(:select_placement_school_form, {}).permit(:school_id, :school_search)
      end
    end
  end
end
