# frozen_string_literal: true

module Trainees
  class PlacementsController < BaseController
    before_action { require_feature_flag(:trainee_placement) }

    def new
      @trainee = trainee
      @placement_form = PlacementForm.new(trainee: @trainee)
    end

    def create
      @trainee = trainee
      @placement_form = PlacementForm.new(
        trainee: @trainee,
        params: new_placement_params,
      )

      if @placement_form.save!
        flash[:success] = I18n.t("flash.trainee_placement_added")
        redirect_to(trainee_path(@trainee))
      else
        render(:new)
      end
    end

  private

    def new_placement_params
      params.fetch(:placement, {}).permit(:school_id, :urn, :name, :address, :postcode)
    end
  end
end
