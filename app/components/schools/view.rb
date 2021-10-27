# frozen_string_literal: true

module Schools
  class View < GovukComponent::Base
    include SummaryHelper
    include SchoolHelper

    def initialize(data_model:, has_errors: false)
      @data_model = data_model
      @has_errors = has_errors
      @lead_school = fetch_lead_school
      @employing_school = fetch_employing_school
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def school_rows
      [
        lead_school_row(not_applicable: lead_school_not_applicable?),
        employing_school_row(not_applicable: employing_school_not_applicable?),
      ].compact
    end

  private

    attr_accessor :data_model, :lead_school, :employing_school, :has_errors

    def lead_school_not_applicable?
      if data_model.is_a?(Schools::FormValidator)
        data_model.lead_school_form.school_not_applicable?
      else
        data_model.lead_school_not_applicable?
      end
    end

    def employing_school_not_applicable?
      if data_model.is_a?(Schools::FormValidator)
        data_model.employing_school_form.school_not_applicable?
      else
        data_model.employing_school_not_applicable?
      end
    end

    def change_paths(school_type)
      {
        lead: edit_trainee_lead_schools_path(trainee),
        employing: edit_trainee_employing_schools_path(trainee),
      }[school_type.to_sym]
    end

    def mappable_field(field_value, field_label, section_url)
      MappableFieldRow.new(
        field_value: field_value,
        field_label: field_label,
        text: t("components.confirmation.missing"),
        action_url: section_url,
        has_errors: has_errors,
      ).to_h
    end

    def fetch_lead_school
      return data_model.lead_school if data_model.respond_to?(:lead_school)

      fetch_school(data_model.lead_school_id)
    end

    def fetch_employing_school
      return data_model.employing_school if data_model.respond_to?(:employing_school)

      fetch_school(data_model.employing_school_id)
    end

    def fetch_school(id)
      return if id.blank?

      School.find(id)
    end
  end
end
