# frozen_string_literal: true

module NationalitiesHelper
  def format_default_nationalities(nationalities)
    formatted_nationalities = []

    nationalities.each do |nationality|
      formatted_nationalities << OpenStruct.new(
        id: nationality.id,
        name: nationality.name.titleize,
        description: I18n.t("views.default_nationalities.#{nationality.name}.description"),
      )
    end

    formatted_nationalities
  end
end
