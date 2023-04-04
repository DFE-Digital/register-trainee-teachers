# frozen_string_literal: true

class ComponentBase < GovukComponent::Base
  def initialize(classes: "", html_attributes: {})
    super(classes:, html_attributes:)
  end

  def default_classes
    []
  end

  def default_attributes
    {}
  end

  def classes
    []
  end
end
