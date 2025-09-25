# frozen_string_literal: true

module PersonalDetails
  class View < ApplicationComponent
    include SanitizeHelper

    def initialize(data_model:, has_errors: false, editable: false, minimal: false, header_level: 2)
      @data_model = data_model
      @nationalities = Nationality.where(id: data_model.nationality_ids)
      @has_errors = has_errors
      @editable = editable
      @minimal = minimal
      @header_level = header_level
    end

    def personal_detail_rows
      [
        full_name_row,
        date_of_birth_row,
        (sex_row unless minimal),
        (nationality_row unless minimal),
      ].compact
    end

  private

    attr_accessor :data_model, :nationalities, :has_errors, :editable, :minimal, :header_level

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def full_name_row
      name = "#{data_model.first_names} #{data_model.middle_names} #{data_model.last_name}"

      default_mappable_field(
        [data_model.first_names, data_model.last_name].any?(&:nil?) ? nil : name,
        t("components.confirmation.personal_detail.full_name"),
      )
    end

    def date_of_birth_row
      default_mappable_field(
        data_model.date_of_birth.is_a?(Date) ? data_model.date_of_birth.strftime("%-d %B %Y") : nil,
        t("components.confirmation.personal_detail.date_of_birth"),
      )
    end

    def sex_row
      default_mappable_field(
        data_model.sex ? I18n.t("components.confirmation.personal_detail.sexes.#{data_model.sex}") : nil,
        t("components.confirmation.personal_detail.sex"),
      )
    end

    def nationality_row
      default_mappable_field(nationality, t("components.confirmation.personal_detail.nationality"))
    end

    def nationality
      return t("components.confirmation.not_provided_from_hesa_update") if nationalities.blank? && trainee.hesa_record?
      return if nationalities.blank?

      if nationalities.size == 1
        nationalities.first.name.titleize_with_hyphens
      else
        sanitize(tag.ul(class: "govuk-list") do
          nationality_names.each do |nationality_name|
            concat(tag.li(nationality_name))
          end
        end)
      end
    end

    def nationality_names
      names = nationalities.map { |nationality| nationality.name.titleize_with_hyphens }
      promote_nationality(names, ::CodeSets::Nationalities::IRISH.titleize_with_hyphens)
      promote_nationality(names, ::CodeSets::Nationalities::BRITISH.titleize_with_hyphens)
    end

    def promote_nationality(array, nationality)
      found = array.delete(nationality)
      array.unshift(nationality) if found
      array
    end

    def default_mappable_field(field_value, field_label)
      { field_value: field_value, field_label: field_label, action_url: edit_trainee_personal_details_path(trainee) }
    end
  end
end
