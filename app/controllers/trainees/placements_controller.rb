# frozen_string_literal: true

module Trainees
  class PlacementsController < BaseController
    before_action { require_feature_flag(:trainee_placement) }

    def new
      @trainee = trainee
      @placement_form = PlacementForm.new(trainee: @trainee, params: new_placement_params)
    end

  private

    def new_placement_params
      params.fetch(:trainee_placement_form, {}).permit(:school_id, :urn, :name, :address, :postcode)
    end
  end
end
