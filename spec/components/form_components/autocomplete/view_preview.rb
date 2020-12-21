# frozen_string_literal: true

module FormComponents
  module Autocomplete
    class ViewPreview < ViewComponent::Preview
      def enhancing_select_list
        render(FormComponents::Autocomplete::View.new(form_field: setup_form))
      end

      def with_custom_class
        render(FormComponents::Autocomplete::View.new(form_field: setup_form, classes: "app-testing-class"))
      end

      def with_custom_html_attributes
        render(FormComponents::Autocomplete::View.new(form_field: setup_form, html_attributes: { "test-html-attribute" => "testing" }))
      end

      def with_show_all_values
        render(FormComponents::Autocomplete::View.new(form_field: setup_form, html_attributes: { "data-show-all-values" => true }))
      end

      def with_default_value
        render(FormComponents::Autocomplete::View.new(form_field: setup_form, html_attributes: { "data-default-value" => "France" }))
      end

    private

      def setup_form
        '<div class="govuk-form-group">
          <label class="govuk-label" for="select-1">
            Select a country
          </label>
          <select class="govuk-select" id="select-1" name="select-1">
            <option value="">Select a country</option>
            <option value="fr">France</option>
            <option value="de">Germany</option>
            <option value="gb">United Kingdom</option>
          </select>
        </div>'
      end
    end
  end
end
