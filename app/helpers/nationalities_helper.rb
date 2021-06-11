# frozen_string_literal: true

module NationalitiesHelper
  include ApplicationHelper

  def checkbox_nationalities(nationalities)
    nationalities.map do |nationality|
      OpenStruct.new(
        id: nationality.name.titleize,
        name: nationality.name.titleize,
        description: I18n.t("views.default_nationalities.#{nationality.name}.description"),
      )
    end
  end

  def nationalities_options(nationalities)
    result = nationalities.map do |nationality|
      OpenStruct.new(id: nationality.name.titleize, name: nationality.name.titleize)
    end
    result.unshift(OpenStruct.new(id: "", name: ""))
    result
  end
end
