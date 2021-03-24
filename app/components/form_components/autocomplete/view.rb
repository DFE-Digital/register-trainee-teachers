# frozen_string_literal: true

module FormComponents
  module Autocomplete
    class View < GovukComponent::Base
      attr_accessor :form_field

      def initialize(form, attribute_name, collection, value_method, text_method, classes: [], html_attributes: {}, **kwargs)
        super(classes: classes, html_attributes: default_html_attributes.merge(html_attributes))

        raw_attribute_value = form.object.send("#{attribute_name}_raw")
        attribute_value = form.object.send(attribute_name)

        # We now need to build the form field inside the component, because the form builder library doesn't allow
        # access to the field object itself before generating html for it. This component now needs to be able to
        # get the value of form attributes and add extra html options. This doesn't seem so bad as the autocomplete
        # component *needs* to have a select field for it to work.
        form_field = form.govuk_collection_select(
          attribute_name, collection, :name, :name, **kwargs.merge(
            html_options: {
              data: { :'text-value' => (raw_attribute_value || attribute_value).to_s }
            }
          ),
        )
        @form_field = form_field
      end

    private

      def default_classes
        %w[]
      end

      def default_html_attributes
        {
          "data-module" => "app-autocomplete",
        }
      end
    end
  end
end
