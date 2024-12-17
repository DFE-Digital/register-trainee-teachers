# frozen_string_literal: true

module CsvFieldSummary
  class View < ViewComponent::Base
    include SummaryHelper

    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def summary_title
      @attributes[:field_name]
    end

    def summary_id
      @attributes[:technical]
    end

    def rows
      @attributes.map do |key, value|
        { key: t("components.csv_field_summary.view.#{key}"), value: value }
      end
    end
  end
end
