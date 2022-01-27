# frozen_string_literal: true

module ApplyApplications
  class InvalidDegreeView
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper

    def initialize(apply_application, degree_slug)
      @apply_application = apply_application
      @invalid_fields = apply_application&.degrees_invalid_data&.fetch(degree_slug, {})&.keys || []
    end

    def summary_content
      if invalid_data?
        I18n.t("views.apply_invalid_data_view.invalid_answers_summary", count: invalid_fields.flatten.size)
      end
    end

    def summary_items_content
      @summary_items_content ||= safe_join(invalid_fields_list)
    end

    def invalid_data?
      invalid_fields.flatten.size.positive?
    end

  private

    attr_reader :apply_application, :invalid_fields

    def invalid_fields_list
      invalid_fields.map do |field|
        tag.li(
          link_to(
            I18n.t("views.apply_invalid_data_view.unrecognised_field_text",
                   invalid_field: get_field_name(field).humanize.upcase_first),
            get_link_anchor(get_field_name(field)),
            class: "govuk-notification-banner__link",
          ),
        )
      end
    end

    def get_link_anchor(field)
      get_form_page_link_anchor(field)
    end

    def get_form_page_link_anchor(field)
      field == "Degree type" ? "##{field.parameterize}" : "#degree-#{field.parameterize}-field"
    end

    def get_field_name(field)
      I18n.t("views.missing_data_view.missing_fields_mapping.#{field}")
    end
  end
end
