# frozen_string_literal: true

class MissingDataView
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  def initialize(form_instance)
    @form_instance = form_instance
    @missing_fields = populate_missing_fields
  end

  def summary_content
    I18n.t("views.missing_data_view.missing_fields_summary", count: missing_fields.size)
  end

  def missing_items_content
    @missing_items_content ||= safe_join(
      missing_fields.map.with_index(1) do |fieldset, index|
        fieldset.map do |field|
          tag.li(
            link_to(
              I18n.t("views.missing_data_view.missing_field_text", missing_field: get_display_name(field)),
              get_link_anchor(field, index),
              class: "govuk-notification-banner__link",
            ),
          )
        end.uniq
      end,
    )
  end

  def missing_data?
    missing_fields.size.positive?
  end

private

  attr_reader :form_instance, :missing_fields

  def get_link_anchor(field, index)
    return "##{get_display_name(field).parameterize}" if missing_fields.size == 1

    "##{get_display_name(field).parameterize}-#{index}"
  end

  def get_display_name(field)
    I18n.t("views.missing_data_view.missing_fields_mapping.#{field}")
  end

  def populate_missing_fields
    form_instance.respond_to?(:missing_fields) ? form_instance.missing_fields : []
  end
end
