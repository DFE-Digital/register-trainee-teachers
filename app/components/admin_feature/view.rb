# frozen_string_literal: true

module AdminFeature
  class View < GovukComponent::Base
    attr_reader :title, :classes

    def initialize(title: nil, classes: [], html_attributes: {})
      @title = title
      @classes = [default_classes, classes]
      super(classes: @classes, html_attributes: default_attributes.merge(html_attributes))
    end

  private

    def default_classes
      %w[app-status-box app-status-box--admin]
    end

    def default_attributes
      {}
    end
  end
end
