# frozen_string_literal: true

class DestroyPlacementForm
  attr_accessor :trainee, :placement

  def initialize(trainee:, placement:)
    @trainee = trainee
    @placement = placement
  end

  def self.find_from_param(trainee, id)
    placement = trainee.placements.find(id)
    new(trainee:, placement:)
  end

  def destroy!
    # return false unless valid?

    @placement.destroy
  end
end
