# frozen_string_literal: true

class ApplyInvalidDataView
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  def initialize(apply_application, degree: nil)
    @apply_application = apply_application
    @degree = degree
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
              I18n.t("views.apply_invalid_data_view.unrecognised_field_text", invalid_field: field.to_s.humanize.upcase_first),
              get_link_anchor(field, index),
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

  attr_reader :apply_application, :invalid_fields, :degree

  def get_link_anchor(field, index)
    return "##{field.parameterize}" if invalid_fields.size == 1

    "##{field.parameterize}-#{index}"
  end

  def populate_invalid_fields
    fields = []

    apply_application&.invalid_data&.each do |section_key, field_and_values|
      field_names = section_key == "degrees" ? populate_degree_fields(field_and_values) : field_and_values.keys
      fields << field_names
    end

    fields.flatten(1)
  end

  def populate_degree_fields(degree_fields)
    return [degree_fields[degree.to_param].keys] if degree.present?

    degree_fields.map do |_k, field_and_values|
      field_and_values.keys
    end
  end
end
