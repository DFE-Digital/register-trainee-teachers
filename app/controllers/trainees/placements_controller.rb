# frozen_string_literal: true

module Trainees
  class PlacementsController < BaseController
    before_action { require_feature_flag(:trainee_placement) }

    def new
      @trainee = trainee
      @placement_form = PlacementForm.new(trainee:)
    end
  end
end
