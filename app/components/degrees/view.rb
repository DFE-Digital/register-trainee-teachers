# frozen_string_literal: true

module Degrees
  class View < GovukComponent::Base
    include ApplicationHelper
    attr_accessor :degrees, :data_model, :show_add_another_degree_button, :show_delete_button

    def initialize(data_model:, show_add_another_degree_button: true, show_delete_button: true)
      @data_model = data_model
      @degrees = @data_model.degrees
      @show_add_another_degree_button = show_add_another_degree_button
      @show_delete_button = show_delete_button
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
          {
            key: "Institution",
            value: degree.institution,
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> institution</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
          },
          {
            key: "Subject",
            value: degree.subject,
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> subject</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
          },
          {
            key: "Degree type",
            value: degree.uk_degree,
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> degree type</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
          },
          {
            key: "Grade",
            value: grade_for(degree),
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> grade</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
          },
          {
            key: "Graduation year",
            value: degree.graduation_year,
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> graduation year</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
          },
        ]
      else
        [
          {
            key: "Country",
            value: degree.country,
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> country</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
          },
          {
            key: "Subject",
            value: degree.subject,
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> subject</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
          },
          {
            key: "Degree type",
            value: degree.non_uk_degree == NON_ENIC ? "UK ENIC not provided" : degree.non_uk_degree,
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> degree type</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
          },
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

    def grade_for(degree)
      return degree.grade += " (#{degree.other_grade})" if degree.other_grade.present?

      degree.grade
    end
  end
end
