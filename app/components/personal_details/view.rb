# frozen_string_literal: true

module PersonalDetails
  class View < GovukComponent::Base
    include SanitizeHelper

    def initialize(data_model:, has_errors: false)
      @data_model = data_model
      @nationalities = Nationality.where(id: data_model.nationality_ids)
      @has_errors = has_errors
    end

    def personal_detail_rows
      [
        full_name_row,
        date_of_birth_row,
        gender_row,
        nationality_row,
      ].compact
    end

  private

    attr_accessor :data_model, :nationalities, :has_errors

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def full_name_row
      name = "#{data_model.first_names} #{data_model.middle_names} #{data_model.last_name}"

      mappable_field(
        [data_model.first_names, data_model.last_name].any?(&:nil?) ? nil : name,
        t("components.confirmation.personal_detail.full_name"),
      )
    end

    def date_of_birth_row
      mappable_field(
        data_model.date_of_birth.is_a?(Date) ? data_model.date_of_birth.strftime("%-d %B %Y") : nil,
        t("components.confirmation.personal_detail.date_of_birth"),
      )
    end

    def gender_row
      mappable_field(
        data_model.gender ? I18n.t("components.confirmation.personal_detail.genders.#{data_model.gender}") : nil,
        t("components.confirmation.personal_detail.gender"),
      )
    end

    def nationality_row
      mappable_field(nationality, t("components.confirmation.personal_detail.nationality"))
    end

    def nationality
      return if nationalities.blank?

      if nationalities.size == 1
        nationalities.first.name.titleize
      else
        sanitize(tag.ul(class: "govuk-list") do
          nationality_names.each do |nationality_name|
            concat tag.li(nationality_name)
          end
        end)
      end
    end

    def nationality_names
      names = nationalities.map { |nationality| nationality.name.titleize }
      promote_nationality(names, Dttp::CodeSets::Nationalities::IRISH.titleize)
      promote_nationality(names, Dttp::CodeSets::Nationalities::BRITISH.titleize)
    end

    def promote_nationality(array, nationality)
      found = array.delete(nationality)
      array.unshift(nationality) if found
      array
    end

    def mappable_field(field_value, field_label)
      MappableFieldRow.new(
        field_value: field_value,
        field_label: field_label,
        text: t("components.confirmation.missing"),
        action_url: edit_trainee_personal_details_path(trainee),
        has_errors: has_errors,
      ).to_h
    end
  end
end
