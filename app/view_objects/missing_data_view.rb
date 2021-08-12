# frozen_string_literal: true

class MissingDataView
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  def initialize(form_instance, multiple_records: false)
    @form_instance = form_instance
    @multiple_records = multiple_records
    @missing_fields = populate_missing_fields
  end

  def summary_content
    I18n.t("views.missing_data_view.missing_fields_summary", count: missing_fields.flatten.size)
  end

  def missing_items_content
    @missing_items_content ||= safe_join(
      missing_fields.map.with_index(1) do |fieldset, index|
        fieldset.map do |field|
          tag.li(
            link_to(
              get_link_text(field, index),
              get_link_anchor(field, index),
              class: "govuk-notification-banner__link",
            ),
          )
        end.uniq
      end,
    )
  end

  def missing_data?
    missing_fields.flatten.size.positive?
  end

private

  attr_reader :form_instance, :missing_fields

  def get_link_anchor(field, index)
    return "##{get_display_name(field).parameterize}" if missing_fields.flatten.size == 1

    "##{get_display_name(field).parameterize}-#{index}"
  end

  def get_link_text(field, index)
    return multiple_record_link_text(field, index) if multiple_records?

    single_record_link_text(field)
  end

  def multiple_records?
    @multiple_records
  end

  def single_record_link_text(field)
    I18n.t("views.missing_data_view.single_missing_field_text_html",
           missing_field: get_display_name(field)).html_safe
  end

  def multiple_record_link_text(field, index)
    I18n.t("views.missing_data_view.multiple_missing_field_text_html",
           missing_field: get_display_name(field),
           section_label: "#{I18n.t("views.missing_data_view.#{form_instance.model_name.i18n_key}")} #{index}").html_safe
  end

  def get_display_name(field)
    I18n.t("views.missing_data_view.missing_fields_mapping.#{field}")
  end

  def populate_missing_fields
    form_instance.respond_to?(:missing_fields) ? form_instance.missing_fields : []
  end
end
