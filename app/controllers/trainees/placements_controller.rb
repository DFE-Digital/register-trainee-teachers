# frozen_string_literal: true

module Trainees
  class PlacementsController < BaseController
    def new
      @trainee = trainee
      @placement_form = PlacementForm.new(trainee:)
    end
  end
end
