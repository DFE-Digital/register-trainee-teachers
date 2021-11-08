# frozen_string_literal: true

module AdminFeature
  class View < GovukComponent::Base
    attr_reader :title

    def initialize(title: nil, classes: [], html_attributes: {})
      @title = title || t("components.admin_feature.title")
      super(classes: classes, html_attributes: default_html_attributes.merge(html_attributes))
    end

  private

    def default_classes
      %w[app-status-box app-status-box--admin]
    end

    def default_html_attributes
      {}
    end
  end
end
