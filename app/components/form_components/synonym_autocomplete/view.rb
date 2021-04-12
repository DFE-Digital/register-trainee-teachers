# frozen_string_literal: true

module FormComponents
  module SynonymAutocomplete
    class View < GovukComponent::Base
      with_content_areas :form_group

      def initialize(classes: [], html_attributes: {})
        super(classes: classes, html_attributes: default_html_attributes.merge(html_attributes))
      end

    private

      def default_classes
        %w[]
      end

      def default_html_attributes
        {
          "data-module" => "app-synonym-autocomplete",
        }
      end
    end
  end
end
