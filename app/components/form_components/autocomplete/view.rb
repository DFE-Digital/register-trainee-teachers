# frozen_string_literal: true

module FormComponents
  module Autocomplete
    class View < GovukComponent::Base
      attr_accessor :form_field

      def initialize(form, attribute_name:, form_field:, classes: [], html_attributes: {})
        @raw_attribute_value = form.object.send("#{attribute_name}_raw")
        @attribute_value = form.object.send(attribute_name)
        super(classes: classes, html_attributes: default_html_attributes.merge(html_attributes))

        @form_field = form_field
      end

    private

      def default_classes
        %w[app-!-autocomplete--max-width-two-thirds]
      end

      def default_html_attributes
        {
          "data-module" => "app-autocomplete",
          "data-default-value" => (@raw_attribute_value || @attribute_value).to_s,
        }
      end
    end
  end
end
