# frozen_string_literal: true

module ApplyApplications
  class InvalidTraineeDataView
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper

    def initialize(trainee, trainee_data_form)
      @trainee = trainee
      @apply_application = trainee.apply_application
      @trainee_data_form = trainee_data_form
      @invalid_fields_count = 0
      @invalid_fields = compute_invalid_fields
    end

    def summary_content
      if invalid_data?
        I18n.t("views.apply_invalid_data_view.invalid_answers_summary", count: invalid_fields_count)
      end
    end

    def summary_items_content
      @summary_items_content ||= safe_join(invalid_fields_list)
    end

    def invalid_data?
      invalid_fields_count.positive?
    end

  private

    attr_reader :trainee,
                :apply_application,
                :invalid_fields,
                :invalid_fields_count,
                :trainee_data_form

    def invalid_fields_list
      items = []

      invalid_fields[:non_degree_fields].each do |field|
        items << tag.li(
          link_to(
            compute_link_text(field),
            "##{get_field_name(field).parameterize}",
            class: "govuk-notification-banner__link",
          ),
        )
      end

      invalid_fields[:degree_fields].each.with_index(1) do |fieldset, index|
        fieldset.each do |degree_record_id, fields|
          fields.flatten.each do |field|
            items << tag.li(
              link_to(
                compute_link_text(field, degree_record_id),
                get_link_anchor(get_field_name(field), index),
                class: "govuk-notification-banner__link",
              ),
            )
          end
        end
      end

      if trainee.degrees.empty?
        link_text = I18n.t("views.apply_invalid_data_view.invalid_answers_summary.degree_missing")
        items << tag.li(link_to(link_text, "#degrees", class: "govuk-notification-banner__link"))
      end

      items
    end

    def get_link_anchor(field, index)
      return "##{field.downcase}" if invalid_fields.size == 1 && field == "Degree type"
      return "##{field.parameterize}" if invalid_fields.size == 1

      "##{field.parameterize}-#{index}"
    end

    def get_form_page_link_anchor(field)
      field == "Degree type" ? "##{field.parameterize}" : "#degree-#{field.parameterize}-field"
    end

    def compute_invalid_fields
      trainee_data_form&.validate

      invalid_fields_map = { non_degree_fields: [], degree_fields: [] }
      missing_fields = trainee_data_form&.missing_fields&.flatten || []

      missing_fields&.each do |field|
        if field.is_a?(Hash)
          invalid_fields_map[:degree_fields] << field
          @invalid_fields_count += field.values.flatten.size
        else
          # Skip if there's already a field with the same prefix e.g. ethnic_*
          # This will prevent the page showing the same error more than once.
          next if invalid_fields_map[:non_degree_fields].join.include?(field.to_s.split("_").first)

          invalid_fields_map[:non_degree_fields] << field
          @invalid_fields_count += 1
        end
      end

      invalid_fields_map
    end

    def compute_link_text(field, degree_record_id = nil)
      if degree_record_id && original_degree_value(field, degree_record_id).present?
        I18n.t("views.apply_invalid_data_view.unrecognised_field_text",
               invalid_field: get_field_name(field).humanize.upcase_first)
      else
        I18n.t("views.missing_data_banner_view.missing_field_text", missing_field: get_field_name(field))
      end
    end

    def get_field_name(field)
      I18n.t("views.missing_data_view.missing_fields_mapping.#{field}")
    end

    def original_degree_value(field, degree_record_id)
      apply_application.degrees_invalid_data&.dig(degree_record_id, field.to_s)
    end
  end
end
