# frozen_string_literal: true

class ApplyInvalidDataView
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  def initialize(apply_application)
    @apply_application = apply_application
    @invalid_fields = populate_invalid_fields
  end

  def summary_content
    return pluralised_invalid_answers_summary if invalid_fields.size > 1

    I18n.t("views.apply_invalid_data_view.invalid_answer_summary")
  end

  def summary_items_content
    @summary_items_content ||= safe_join(
      invalid_fields.map do |field|
        tag.li(
          link_to(
            I18n.t("views.apply_invalid_data_view.unrecognised_field_text", invalid_field: field.to_s.upcase_first),
            "##{field}",
            class: "govuk-notification-banner__link",
          ),
        )
      end,
    )
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

  def pluralised_invalid_answers_summary
    I18n.t("views.apply_invalid_data_view.invalid_answers_summary", total_invalid_fields: invalid_fields.size)
  end
end
