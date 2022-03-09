# frozen_string_literal: true

class SelectOption
  attr_reader :value, :text

  def initialize(value:, text:)
    @value = value
    @text = text
  end
end
