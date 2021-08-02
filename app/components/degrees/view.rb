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
        "#{degree.uk_degree}: #{degree.subject&.downcase}"
      else
        "Non-UK #{degree.non_uk_degree_non_enic? ? 'degree' : degree.non_uk_degree}: #{degree.subject.downcase}"
      end
    end

    def get_degree_rows(degree)
      if degree.uk?
        [
          mappable_field_row(degree, :institution, "Institution"),
          mappable_field_row(degree, :subject, "Subject"),
          mappable_field_row(degree, :uk_degree, "Degree type"),
          {
            key: "Grade",
            value: grade_for(degree),
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> grade</span>'.html_safe,
                                  edit_trainee_degree_path(trainee, degree)),
          },
          {
            key: "Graduation year",
            value: degree.graduation_year,
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> graduation year</span>'.html_safe,
                                  edit_trainee_degree_path(trainee, degree)),
          },
        ]
      else
        [
          mappable_field_row(degree, :country, "Country"),
          mappable_field_row(degree, :subject, "Subject"),
          mappable_field_row(degree, :non_uk_degree, "Degree type", non_uk_degree_type(degree)),
          {
            key: "Graduation year",
            value: degree.graduation_year,
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> graduation year</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
          },
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

      degree.grade
    end

    def mappable_field_row(degree, field_name, field_label, field_value = nil)
      MappableFieldRow.new(invalid_data: trainee.apply_application&.degrees_invalid_data,
                           record_id: degree.to_param,
                           field_name: field_name,
                           field_value: field_value || degree.public_send(field_name),
                           field_label: field_label,
                           action_url: edit_trainee_degree_path(trainee, degree),
                           has_errors: has_errors).to_h
    end
  end
end
