# frozen_string_literal: true

module FormComponents
  module CountryAutocomplete
    class View < Autocomplete::View
    private

      def default_classes
        %w[]
      end

      def default_html_attributes
        {
          id: attribute_name.to_s,
          "data-module" => "app-country-autocomplete",
          "data-default-value" => (@raw_attribute_value || @attribute_value).to_s,
        }
      end
    end
  end
end
