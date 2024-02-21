# frozen_string_literal: true

class TraineeSerializer
  def initialize(trainee)
    @trainee = trainee
  end

  def as_hash
    @trainee.attributes.merge(
      placements: @trainee.placements.map(&:attributes),
      degrees: @trainee.degrees.map(&:attributes),
    )
  end
end
