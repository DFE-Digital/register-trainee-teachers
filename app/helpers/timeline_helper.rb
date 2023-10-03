# frozen_string_literal: true

module TimelineHelper
  def items_are_single_values?(event)
    event.items&.first.is_a?(String)
  end
end
