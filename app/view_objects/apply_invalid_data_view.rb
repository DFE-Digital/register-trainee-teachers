# frozen_string_literal: true

class ApplyInvalidDataView
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  def initialize(apply_application)
    @apply_application = apply_application
    @invalid_fields = populate_invalid_fields
  end

  def summary_content
    I18n.t("views.apply_invalid_data_view.invalid_answers_summary", count: invalid_fields.size)
  end

  def summary_items_content
    @summary_items_content ||= safe_join(
      invalid_fields.map do |field|
        tag.li(
          link_to(
            I18n.t("views.apply_invalid_data_view.unrecognised_field_text", invalid_field: field.to_s.humanize.upcase_first),
            "##{section_key_id_prefix}-#{field.dasherize}-label",
            class: "govuk-notification-banner__link",
          ),
        )
      end,
    )
  end

  def invalid_data?
    invalid_fields.size.positive?
  end

private

  attr_reader :apply_application, :invalid_fields

  def populate_invalid_fields
    fields = []

    apply_application.invalid_data.each do |section_key, field_and_values|
      field_names = section_key == "degrees" ? populate_degree_fields(field_and_values) : field_and_values.keys
      fields << field_names
    end

    fields.flatten
  end

  def populate_degree_fields(degree_fields)
    degree_fields.map do |_k, field_and_values|
      field_and_values.keys
    end
  end

  def section_key_id_prefix
    apply_application.invalid_data.map { |section_key, _field_and_values| section_key }.join
  end
end
