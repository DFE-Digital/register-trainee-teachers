# frozen_string_literal: true

module FormComponents
  module CountryAutocomplete
    class View < GovukComponent::Base
      def initialize(attribute_name:, form_field:, classes: [], html_attributes: {})
        @attribute_name = attribute_name
        @form_field = form_field
        super(classes: classes, html_attributes: default_html_attributes.merge(html_attributes))
      end

    private

      attr_accessor :form_field, :attribute_name

      def default_classes
        %w[]
      end

      def default_html_attributes
        {
          id: attribute_name.to_s,
          "data-module" => "app-country-autocomplete",
        }
      end
    end
  end
end
