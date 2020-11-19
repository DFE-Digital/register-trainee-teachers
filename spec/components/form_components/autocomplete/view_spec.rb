# frozen_string_literal: true

require "rails_helper"

module FormComponents
  module Autocomplete
    describe View do
      alias_method :component, :page

      it "supports custom classes on the parent container" do
        render_inline(View.new(form_field: setup_form, classes: "test-css-class"))
        expect(component).to have_selector(".test-css-class")
      end

      it "supports custom html attributes on the parent container" do
        render_inline(View.new(form_field: setup_form, html_attributes: { "test-attribute" => "my-custom-attribute" }))
        expect(component).to have_selector('[test-attribute="my-custom-attribute"]')
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
