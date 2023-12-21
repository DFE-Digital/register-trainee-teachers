# frozen_string_literal: true

class InformationSummary::View < ViewComponent::Base
  renders_one :header

  def initialize(renderable: false)
    @renderable = renderable
  end

  def render?
    renderable
  end

private

  attr_reader :renderable
end
