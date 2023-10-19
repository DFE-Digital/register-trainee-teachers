# frozen_string_literal: true

module Trainees
  class PlacementsController < BaseController
    before_action :require_feature_flag

    def new
      @trainee = trainee
      @placement_form = PlacementForm.new(trainee:)
    end

  private

    def require_feature_flag
      redirect_to(not_found_path) unless FeatureService.enabled?(:trainee_placement)
    end
  end
end
