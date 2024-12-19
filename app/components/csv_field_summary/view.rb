# frozen_string_literal: true

module CsvFieldSummary
  class View < ViewComponent::Base
    include SummaryHelper

    attr_reader :attributes

    MARKDOWN_ATTRIBUTES = %w[description format example].freeze

    def initialize(attributes)
      @attributes = attributes
    end

    def summary_title
      @attributes["field_name"]
    end

    def summary_id
      @attributes["technical"].parameterize
    end

    def rows
      @attributes.map do |key, value|
        {
          key: t("components.csv_field_summary.view.#{key}"),
          value: convert_value_to_html(key, value),
        }
      end
    end

  private

    def markdown_render
      @markdown_render ||= Redcarpet::Render::HTML.new(
        link_attributes: { class: "govuk-link" },
        paragraph_attributes: { class: "govuk-body" },
      )
    end

    def convert_value_to_html(key, value)
      if MARKDOWN_ATTRIBUTES.include?(key)
        value.is_a?(String) ? Redcarpet::Markdown.new(markdown_render).render(value).html_safe : ""
      else
        value
      end
    end
  end
end
