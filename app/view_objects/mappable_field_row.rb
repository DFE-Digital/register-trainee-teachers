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
    @has_errors = options[:has_errors]
    @text = options[:text]
    @apply_draft = options[:apply_draft] || false
    @non_editable = options[:non_editable]
  end

  def to_h
    { key: field_label }.merge(value_attribute).merge(action_attributes)
  end

private

  attr_accessor :invalid_data, :record_id, :field_name, :field_value, :field_label, :text, :action_url, :has_errors, :apply_draft, :non_editable

  def value_attribute
    return { value: unmapped_value.html_safe } if field_value.nil?

    { value: field_value }
  end

  def action_attributes
    return {} if field_value.nil? || action_url.nil? || non_editable

    { action_href: action_url, action_text: I18n.t(:change), action_visually_hidden_text: field_label.downcase }
  end

  def unmapped_value
    <<~HTML
      <div class="govuk-inset-text app-inset-text--narrow-border app-inset-text--#{has_errors ? 'error' : 'important'} app-inset-text--no_padding">
        <p class="app-inset-text__title govuk-!-margin-bottom-2">#{error_message_prefix}#{field_label} is #{original_value ? 'not recognised' : text}</p>
        #{original_value_html}
        #{unmapped_value_anchor}
      </div>
    HTML
  end

  def unmapped_value_anchor
    unless non_editable
      %(<div>
    <a class="govuk-link govuk-link--no-visited-state app-summary-list__link--invalid" name="#{field_label.downcase}" href="#{action_url}">
      #{field_hint_text(field_label)}
    </a>
  </div>)
    end
  end

  def error_message_prefix
    has_errors ? '<span class="govuk-visually-hidden">Error:</span>' : ""
  end

  def original_value_html
    %(<div class="govuk-!-margin-bottom-1">#{original_value}</div>) if original_value
  end

  def original_value
    invalid_data&.dig(record_id, field_name.to_s)
  end

  def field_hint_text(field_label)
    return I18n.t("views.mappable_field_row.default_hint_text_html", field_label: field_label.downcase) unless apply_draft

    I18n.t("views.mappable_field_row.apply_field_hint_text_html", field_label: field_label.downcase)
  end
end
