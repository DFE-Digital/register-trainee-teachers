# frozen_string_literal: true

module Degrees
  class View < ApplicationComponent
    include ApplicationHelper

    def initialize(data_model:, show_add_another_degree_button: true, show_delete_button: true, has_errors: false, editable: false, header_level: 2)
      @data_model = data_model
      @degrees = @data_model.degrees
      @has_errors = has_errors
      @editable = editable
      @show_add_another_degree_button = show_button(show_add_another_degree_button)
      @show_delete_button = show_button(show_delete_button)
      @header_level = header_level
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def degree_title(degree)
      if degree.uk?
        return "#{degree.uk_degree}: #{degree.subject&.downcase}" if degree.uk_degree && degree.subject

        degree.uk_degree.presence || degree.subject.presence
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

    def show_button(button)
      return false if !editable

      button
    end

  private

    attr_accessor :degrees, :data_model, :show_add_another_degree_button, :show_delete_button, :has_errors, :editable, :header_level

    def non_uk_degree_type(degree)
      degree.non_uk_degree == NON_ENIC ? "UK ENIC not provided" : degree.non_uk_degree
    end

    def grade_for(degree)
      return degree.grade += " (#{degree.other_grade})" if degree.other_grade.present?

      degree.grade
    end

    def mappable_field_row(degree, field_name, field_label, field_value = nil)
      { degree:, field_name:, field_label:, field_value: }
    end
  end
end
