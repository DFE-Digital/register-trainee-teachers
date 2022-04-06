# frozen_string_literal: true

module SystemAdmin
  class DttpTraineesController < ApplicationController
    def show
      trainee = Trainee.from_param(params[:id])
      render(json: trainee.dttp_trainee&.response)
    end

    def placement_assignments
      trainee = Trainee.from_param(params[:id])
      dttp_trainee = trainee.dttp_trainee
      render(json: dttp_trainee&.placement_assignments&.map(&:response))
    end
  end
end
