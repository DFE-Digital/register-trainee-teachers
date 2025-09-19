# frozen_string_literal: true

module MappableSummary
  class View < ApplicationComponent
    renders_one :header_actions

    def initialize(trainee:, title:, rows:, editable:, has_errors:, id_suffix: nil, header_level: 3)
      @trainee = trainee
      @title = title
      @rows = rows
      @editable = editable
      @has_errors = has_errors
      @id_suffix = id_suffix
      @header_level = header_level
    end

    def mappable_rows
      rows.map do |row|
        if row[:custom_value] == true
          custom_row(row)
        elsif row[:degree].present?
          mappable_degree_field_row(row[:degree], row[:field_name], row[:field_label], row[:field_value])
        else
          mappable_field(row[:field_value], row[:field_label], row[:action_url])
        end
      end
    end

    def action_attributes(row)
      return {} if row[:action_href].nil? || !editable

      row.slice(:action_href, :action_text, :action_visually_hidden_text)
    end

    def custom_row(row)
      row.slice(:key, :value).merge(action_attributes(row))
    end

  private

    attr_reader :title, :rows, :editable, :trainee, :has_errors, :id_suffix, :header_level

    def mappable_field(field_value, field_label, action_url)
      MappableFieldRow.new(
        field_value: field_value,
        field_label: field_label,
        text: "missing",
        action_url: action_url,
        has_errors: has_errors,
        apply_draft: trainee.apply_application?,
        editable: editable,
      ).to_h
    end

    def mappable_degree_field_row(degree, field_name, field_label, field_value)
      MappableFieldRow.new(
        invalid_data: trainee.apply_application&.degrees_invalid_data,
        record_id: degree.to_param,
        field_name: field_name,
        field_value: field_value || degree.public_send(field_name),
        field_label: field_label,
        text: "missing",
        action_url: edit_trainee_degree_path(trainee, degree),
        has_errors: has_errors,
        apply_draft: trainee.apply_application?,
        editable: editable,
      ).to_h
    end
  end
end
