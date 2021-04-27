# frozen_string_literal: true

module NationalitiesHelper
  def format_nationalities(nationalities, description: true, empty_option: false)
    formatted_nationalities = []

    formatted_nationalities << OpenStruct.new(id: "", name: "") if empty_option

    nationalities.each do |nationality|
      formatted_nationality = OpenStruct.new(
        id: nationality.name.titleize,
        name: nationality.name.titleize,
      )

      if description
        formatted_nationality.description = I18n.t(
          "views.default_nationalities.#{nationality.name}.description",
        )
      end

      formatted_nationalities << formatted_nationality
    end

    formatted_nationalities
  end
end
