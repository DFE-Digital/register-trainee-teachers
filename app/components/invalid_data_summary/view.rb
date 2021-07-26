# frozen_string_literal: true

class InvalidDataSummary::View < GovukComponent::Base
  def initialize(data: "{}", section: "degrees")
    @data = data
    @section = section
  end

  def invalid_fields
    JSON(data)[section].values.first
  end

  def render?
    return if data.nil?

    JSON(data)&.any?
  end

private

  attr_reader :data, :section
end
