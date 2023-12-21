# frozen_string_literal: true

module FormComponents
  module Autocomplete
    class View < GovukComponent::Base
      def initialize(form, attribute_name:, form_field:, classes: [], html_attributes: {})
        @raw_attribute_value = form.object.send("#{attribute_name}_raw")
        @attribute_value = form.object.send(attribute_name)
        @attribute_name = attribute_name
        @form_field = form_field
        @classes = [default_classes, classes]
        super(classes: @classes, html_attributes: default_attributes.merge(html_attributes))
      end

    private

      attr_accessor :form_field, :attribute_name, :classes

      def default_classes
        %w[app-!-autocomplete--max-width-two-thirds]
      end

      def default_attributes
        {
          id: attribute_name.to_s,
          "data-module" => "app-autocomplete",
          "data-default-value" => (@raw_attribute_value || @attribute_value).to_s,
        }
      end
    end
  end
end
