# frozen_string_literal: true

class TraineeSerializer
  def initialize(trainee)
    @trainee = trainee
  end

  def as_json
    @trainee.attributes.merge(
      placements: @trainee.placements.map(&:attributes),
      degrees: @trainee.degrees.map(&:attributes),
    ).to_json
  end
end
