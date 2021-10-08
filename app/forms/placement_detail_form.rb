# frozen_string_literal: true

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
