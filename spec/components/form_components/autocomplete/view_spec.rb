# frozen_string_literal: true

require "rails_helper"

module FormComponents
  module Autocomplete
    class ExampleModel
      include ActiveModel::Model

      attr_accessor :id, :country, :country_raw
    end

    describe View do
      include ActionView::Helpers::FormHelper

      alias_method :component, :page

      it "supports custom classes on the parent container" do
        render_inline(View.new(form, attribute_name: :country, form_field: form_field, classes: "test-css-class"))
        expect(component).to have_css(".test-css-class")
      end

      it "supports custom html attributes on the parent container" do
        render_inline(View.new(form, attribute_name: :country, form_field: form_field, html_attributes: { "test-attribute" => "my-custom-attribute" }))
        expect(component).to have_css('[test-attribute="my-custom-attribute"]')
      end

    private

      attr_accessor :output_buffer

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
