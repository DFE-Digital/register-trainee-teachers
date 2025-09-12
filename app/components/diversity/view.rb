# frozen_string_literal: true

module Diversity
  class View < ApplicationComponent
    include SanitizeHelper

    def initialize(data_model:, has_errors: false, editable: false, header_level: 2)
      @data_model = data_model
      @has_errors = has_errors
      @editable = editable
      @header_level = header_level
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def diversity_information_rows
      rows = [diversity_disclosure_row]

      if data_model.diversity_disclosed?
        rows << ethnicity_row

        rows << disability_row
      end

      rows
    end

  private

    attr_accessor :data_model, :has_errors, :editable, :header_level

    def diversity_disclosure_row
      field_value = data_model.diversity_disclosure ? t("components.confirmation.diversity.diversity_disclosure.#{data_model.diversity_disclosure}") : nil
      mappable_field(
        field_value,
        t("components.confirmation.diversity.diversity_disclosure_title"),
        edit_trainee_diversity_disclosure_path(trainee),
      )
    end

    def ethnicity_row
      mappable_field(
        ethnic_group_content,
        t("components.confirmation.diversity.ethnicity_title"),
        edit_trainee_diversity_ethnic_group_path(trainee),
      )
    end

    def disability_row
      mappable_field(
        disability_content,
        t("components.confirmation.diversity.disability_title"),
        edit_trainee_diversity_disability_disclosure_path(trainee),
      )
    end

    def ethnic_group_content
      return unless data_model.ethnic_group
      return if data_model.ethnic_group != Diversities::ETHNIC_GROUP_ENUMS[:not_provided] && data_model.ethnic_background.blank?

      value = t("components.confirmation.diversity.ethnic_groups.#{data_model.ethnic_group}")

      if data_model.ethnic_background.present? && data_model.ethnic_background != Diversities::NOT_PROVIDED
        value += " (#{trainee_ethnic_background})"
      end

      value
    end

    def disability_content
      return if disabilities_incomplete?

      tag.p(disability_selection, class: "govuk-body") + selected_disability_options
    end

    def disability_selection
      return nil unless data_model.disability_disclosure

      t("components.confirmation.diversity.disability_disclosure.#{data_model.disability_disclosure}")
    end

    def selected_disability_options
      return nil if data_model.disabilities.empty?

      selected = tag.p("Disabilities shared:", class: "govuk-body")

      selected + sanitize(tag.ul(class: "govuk-list govuk-list--bullet") do
        render_disabilities
      end)
    end

    def disabilities_incomplete?
      return true if disability_selection.nil?

      data_model.disability_disclosure == Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] && data_model.disabilities.empty?
    end

    def render_disabilities
      data_model.disabilities.each do |disability|
        if disability.name == Diversities::OTHER
          render_additional_disability(disability)
        else
          concat(tag.li(disability_name_for(disability)))
        end
      end
    end

    def render_additional_disability(disability)
      concat(tag.li("#{disability_name_for(disability)} #{additional_disability_for(disability)}"))
    end

    def additional_disability_for(disability)
      additional_disability = if data_model.is_a?(Trainee)
                                data_model.trainee_disabilities.where(disability_id: disability.id).first.additional_disability
                              else
                                data_model.additional_disability
                              end

      return if additional_disability.blank?

      "(#{additional_disability})"
    end

    def disability_name_for(disability)
      disability.name.downcase
    end

    def trainee_ethnic_background
      data_model.additional_ethnic_background.presence || data_model.ethnic_background
    end

    def mappable_field(field_value, field_label, action_url)
      { field_value:, field_label:, action_url: }
    end
  end
end
