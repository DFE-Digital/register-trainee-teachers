# frozen_string_literal: true

class TraineeSerializer
  def initialize(trainee)
    @trainee = trainee
  end

  def as_json
    @trainee.to_json
  end
end
