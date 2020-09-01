class TraineePersonalDetails
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
      trainee_id
      first_names
      last_name
      gender
      date_of_birth
      nationality
      ethnicity
      disability
    ]
  end
end
