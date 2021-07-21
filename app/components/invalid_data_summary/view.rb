# frozen_string_literal: true

class InvalidDataSummary::View < GovukComponent::Base
  def initialize(data: {})
    @data = data
  end

  def invalid_fields
    data.values.flatten.map(&:keys).flatten
  end

  def render?
    data&.any?
  end

private

  attr_reader :data
end
