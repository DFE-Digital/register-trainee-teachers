# frozen_string_literal: true

class InvalidDataSummary::View < GovukComponent::Base
  def initialize(data: "{}")
    @data = data
  end

  def invalid_fields
    JSON(data).values.flatten.map(&:values).flatten
  end

  def render?
    return if data.nil?

    JSON(data)&.any?
  end

private

  attr_reader :data
end
