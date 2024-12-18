# frozen_string_literal: true

module CsvFieldSummary
  class View < ViewComponent::Base
    include SummaryHelper

    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def summary_title
      @attributes["field_name"]
    end

    def summary_id
      @attributes["technical"]
    end

    def rows
      render = Redcarpet::Render::HTML.new(
        link_attributes: { class: "govuk-link" },
        paragraph_attributes: { class: "govuk-body" },
      )

      @attributes.map do |key, value|
        html_value = value.is_a?(String) ? Redcarpet::Markdown.new(render).render(value).html_safe : ''
        { key: t("components.csv_field_summary.view.#{key}"), value: html_value }
      end
    end
  end
end
