# frozen_string_literal: true

module Degrees
  class View < GovukComponent::Base
    include ApplicationHelper

    def initialize(data_model:, show_add_another_degree_button: true, show_delete_button: true, has_errors: false)
      @data_model = data_model
      @degrees = @data_model.degrees
      @show_add_another_degree_button = show_add_another_degree_button
      @show_delete_button = show_delete_button
      @has_errors = has_errors
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def degree_title(degree)
      if degree.uk?
        degree.subject ? "#{degree.uk_degree}: #{degree.subject&.downcase}" : degree.uk_degree
      elsif degree.subject
        "Non-UK #{degree.non_uk_degree_non_enic? ? 'degree' : degree.non_uk_degree}: #{degree.subject&.downcase}"
      else
        "Non-UK #{degree.non_uk_degree_non_enic? ? 'degree' : degree.non_uk_degree}"
      end
    end

    def get_degree_rows(degree)
      if degree.uk?
        [
          mappable_field_row(degree, :institution, t("components.degrees.institution")),
          mappable_field_row(degree, :subject, t("components.degrees.subject")),
          mappable_field_row(degree, :uk_degree, t("components.degrees.degree_type")),
          mappable_field_row(degree, :grade, t("components.degrees.grade"), grade_for(degree)),
          mappable_field_row(degree, :graduation_year, t("components.degrees.graduation_year")),
        ]
      else
        [
          mappable_field_row(degree, :country, t("components.degrees.country")),
          mappable_field_row(degree, :subject, t("components.degrees.subject")),
          mappable_field_row(degree, :non_uk_degree, t("components.degrees.degree_type"), non_uk_degree_type(degree)),
          mappable_field_row(degree, :graduation_year, t("components.degrees.graduation_year")),
        ]
      end
    end

    def degree_button_text
      t("components.degrees.add_another_degree")
    end

  private

    attr_accessor :degrees, :data_model, :show_add_another_degree_button, :show_delete_button, :has_errors

    def non_uk_degree_type(degree)
      degree.non_uk_degree == NON_ENIC ? "UK ENIC not provided" : degree.non_uk_degree
    end

    def grade_for(degree)
      return degree.grade += " (#{degree.other_grade})" if degree.other_grade.present?

      degree.grade&.capitalize
    end

    def mappable_field_row(degree, field_name, field_label, field_value = nil)
      MappableFieldRow.new(
        invalid_data: trainee.apply_application&.degrees_invalid_data,
        record_id: degree.to_param,
        field_name: field_name,
        field_value: field_value || degree.public_send(field_name),
        field_label: field_label,
        text: t("components.confirmation.missing"),
        action_url: edit_trainee_degree_path(trainee, degree),
        has_errors: has_errors,
        apply_draft: trainee.apply_application?,
      ).to_h
    end
  end
end
