# frozen_string_literal: true

module FormComponents
  module Autocomplete
    class ViewPreview < ViewComponent::Preview
      include ActionView::Helpers::FormHelper

      def enhancing_select_list
        render(FormComponents::Autocomplete::View.new(form, attribute_name: :country, form_field: form_field))
      end

      def with_custom_class
        render(FormComponents::Autocomplete::View.new(form, attribute_name: :country, form_field: form_field, classes: "app-testing-class"))
      end

      def with_custom_html_attributes
        render(FormComponents::Autocomplete::View.new(form, attribute_name: :country, form_field: form_field, html_attributes: { "test-html-attribute" => "testing" }))
      end

      def with_default_value
        render(FormComponents::Autocomplete::View.new(form, attribute_name: :country, form_field: form_field, html_attributes: { "data-default-value" => "France" }))
      end

    private

      attr_accessor :output_buffer

      class ExampleModel
        include ActiveModel::Model

        attr_accessor :id, :country, :country_raw
      end

      def form_field
        <<~EOSQL
          <div class="govuk-form-group">
            <label class="govuk-label" for="select-1">
              Select a country
            </label>
            <select class="govuk-select" id="select-1" name="select-1">
              <option value="">Select a country</option>
              <option value="fr">France</option>
              <option value="de">Germany</option>
              <option value="gb">United Kingdom</option>
            </select>
          </div>
        EOSQL
      end

      def form
        form_for ExampleModel.new, url: "example.com" do |f|
          return f
        end
      end
    end
  end
end
