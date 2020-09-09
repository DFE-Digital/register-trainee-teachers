class TraineeContactDetails
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
    attrs = address_fields
    attrs.merge(trainee.attributes.select { |k, _v| relevant_fields.include?(k) })
  end

  def address_fields
    {
      address: address_values,
    }
  end

  def address_values
    return "" if trainee.address_line_one.blank?

    "#{trainee.address_line_one}, #{trainee.address_line_two}, #{trainee.town_city}, #{trainee.county}"
  end

  def relevant_fields
    %w[
      postcode
      phone_number
      email
    ]
  end
end
