# frozen_string_literal: true

class InvalidDataSummary::View < GovukComponent::Base
  def initialize(data: "{}", section: "degrees")
    @data = data
    @section = section
  end

  def invalid_fields
    data[section].values.first
  end

  def render?
    return if data.empty?

    data&.any?
  end

private

  attr_reader :data, :section
end
