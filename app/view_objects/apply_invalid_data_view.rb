# frozen_string_literal: true

class ApplyInvalidDataView
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  APPLY_INVALID_DATA_FIELDS_ORDER = %w[
    institution
    country
    subject
    uk_degree
    non_uk_degree
    grade
    graduation_year
  ].freeze

  def initialize(apply_application, degree: nil, on_form_page: false, degrees_sort_order: [])
    @apply_application = apply_application
    @degree = degree
    @on_form_page = on_form_page
    @degrees_sort_order = degrees_sort_order
    @invalid_fields = populate_invalid_fields
  end

  def summary_content
    I18n.t("views.apply_invalid_data_view.invalid_answers_summary", count: invalid_fields.flatten.size)
  end

  def summary_items_content
    @summary_items_content ||= safe_join(
      invalid_fields.map.with_index(1) do |fieldset, index|
        fieldset.map do |field|
          tag.li(
            link_to(
              I18n.t("views.apply_invalid_data_view.unrecognised_field_text", invalid_field: get_field_name(field).humanize.upcase_first),
              get_link_anchor(get_field_name(field), index),
              class: "govuk-notification-banner__link",
            ),
          )
        end
      end,
    )
  end

  def invalid_data?
    invalid_fields.flatten.size.positive?
  end

private

  attr_reader :apply_application, :invalid_fields, :degree, :on_form_page, :degrees_sort_order

  def get_link_anchor(field, index)
    return get_form_page_link_anchor(field) if on_form_page
    return "##{field.downcase}" if invalid_fields.size == 1 && field == "Degree type"
    return "##{field.parameterize}" if invalid_fields.size == 1

    "##{field.parameterize}-#{index}"
  end

  def get_form_page_link_anchor(field)
    field == "Degree type" ? "##{field.parameterize}" : "#degree-#{field.parameterize}-field"
  end

  def populate_invalid_fields
    fields = []

    apply_application&.invalid_data&.each do |section_key, field_and_values|
      field_names = section_key == "degrees" ? populate_degree_fields(field_and_values) : field_and_values.keys
      fields << field_names
    end

    fields.flatten(1).map do |degree_fields|
      degree_fields.sort { |a, b| APPLY_INVALID_DATA_FIELDS_ORDER.find_index(a) <=> APPLY_INVALID_DATA_FIELDS_ORDER.find_index(b) }
    end
  end

  def populate_degree_fields(degree_fields)
    return [] unless degree_sort_order_in(degree_fields)

    return [degree_fields[degree.to_param]&.keys].compact if degree.present?
    return degree_fields.map { |_slug, field| field.keys } if degrees_sort_order.size <= 1

    degrees_sort_order.map do |slug|
      degree_fields[slug].keys
    end
  end

  def get_field_name(field)
    I18n.t("views.missing_data_view.missing_fields_mapping.#{field}")
  end

  def degree_sort_order_in(degree_fields)
    degrees_sort_order.all? { |slug| degree_fields.key?(slug) }
  end
end
