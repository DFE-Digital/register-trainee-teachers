# frozen_string_literal: true

module PersonalDetails
  class View < GovukComponent::Base
    include SanitizeHelper

    attr_accessor :data_model, :nationalities

    def initialize(data_model:)
      @data_model = data_model
      @nationalities = Nationality.where(id: data_model.nationality_ids)
      @not_provided_copy = I18n.t("components.confirmation.not_provided")
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def full_name
      return @not_provided_copy unless data_model.first_names && data_model.last_name

      "#{data_model.first_names} #{data_model.middle_names} #{data_model.last_name}"
    end

    def date_of_birth
      return @not_provided_copy unless data_model.date_of_birth.is_a?(Date)

      data_model.date_of_birth.strftime("%-d %B %Y")
    end

    def gender
      return @not_provided_copy unless data_model.gender

      I18n.t("components.confirmation.personal_detail.genders.#{data_model.gender}")
    end

    def nationality_row
      MappableFieldRow.new(field_value: nationality,
                           field_label: "Nationality",
                           text: t("components.confirmation.missing"),
                           action_url: edit_trainee_personal_details_path(trainee)).to_h
    end

  private

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
  end
end
