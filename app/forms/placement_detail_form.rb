# frozen_string_literal: true

# TODO: Flesh out - this is just a placeholder
class PlacementDetailForm
  include ActiveModel::Model

  def initialize(trainee)
    @trainee = trainee
    super(fields)
  end

  def fields
    {}
  end
end
