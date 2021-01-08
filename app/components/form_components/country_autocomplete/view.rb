# frozen_string_literal: true

module FormComponents
  module CountryAutocomplete
    class View < GovukComponent::Base
      attr_accessor :form_field

      def initialize(form_field:, classes: [], html_attributes: {})
        super(classes: classes, html_attributes: default_html_attributes.merge(html_attributes))
        @form_field = form_field
      end

    private

      def default_classes
        %w[]
      end

      def default_html_attributes
        {
          "data-module" => "app-country-autocomplete",
        }
      end
    end
  end
end
