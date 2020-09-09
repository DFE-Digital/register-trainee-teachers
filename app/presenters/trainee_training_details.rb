class TraineeTrainingDetails
  attr_reader :trainee

  def initialize(trainee)
    @trainee = trainee
  end

  def call
    relevant_attributes.map { |k, v|
      [Trainee.human_attribute_name(k), v]
    }.to_h
  end

private

  def relevant_attributes
    trainee.attributes.select { |k, _v| relevant_fields.include?(k) }
  end

  def relevant_fields
    %w[
      start_date
      full_time_part_time
      teaching_scholars
    ]
  end
end
