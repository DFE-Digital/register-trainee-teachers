# frozen_string_literal: true

module Degrees
  class CreateFromDttpPlacementAssignmentJob < ApplicationJob
    queue_as :dttp

    def perform(trainee)
      CreateFromDttpPlacementAssignment.call(trainee: trainee)
    end
  end
end
