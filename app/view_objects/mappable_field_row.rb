# frozen_string_literal: true

class MappableFieldRow
  include GovukLinkHelper
  include ActionView::Helpers::UrlHelper

  def initialize(options = {})
    @invalid_data = options[:invalid_data]
    @record_id = options[:record_id]
    @field_name = options[:field_name]
    @field_value = options[:field_value]
    @field_label = options[:field_label]
    @action_url = options[:action_url]
    @text = options[:text] || "not recognised"
  end

  def to_h
    { key: field_label }.merge(value_attribute).merge(action_attribute)
  end

private

  attr_accessor :invalid_data, :record_id, :field_name, :field_value, :field_label, :text, :action_url

  def value_attribute
    return { value: unmapped_value.html_safe } if field_value.nil?

    { value: field_value }
  end

  def action_attribute
    return {} if field_value.nil?

    html = %(Change <span class="govuk-visually-hidden">#{field_label.downcase}</span>).html_safe
    { action: govuk_link_to(html, action_url) }
  end

  def unmapped_value
    <<~HTML
      <div class="govuk-inset-text app-inset-text--narrow-border app-inset-text--important app-inset-text--no_padding">
        <p class="app-inset-text__title govuk-!-margin-bottom-2">#{field_label} is #{text}</p>
        #{original_value_html}
        <div>
          <a class="govuk-link govuk-link--no-visited-state app-summary-list__link--invalid" href="#{action_url}">
            Review the trainee’s answer<span class="govuk-visually-hidden"> for #{field_label.downcase}</span>
          </a>
        </div>
      </div>
    HTML
  end

  def original_value_html
    %(<div class="govuk-!-margin-bottom-1">#{original_value}</div>) if original_value
  end

  def original_value
    invalid_data&.dig(record_id, field_name.to_s)
  end
end
