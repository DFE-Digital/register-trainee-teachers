# frozen_string_literal: true

module NationalitiesHelper
  include ApplicationHelper

  def checkbox_nationalities(nationalities)
    nationalities.map do |nationality|
      NationalityOption.new(
        id: nationality.name.to_title,
        name: nationality.name.to_title,
        description: I18n.t("views.default_nationalities.#{nationality.name}.description"),
      )
    end
  end

  def nationalities_options(nationalities)
    result = nationalities.map do |nationality|
      NationalityOption.new(id: nationality.name.to_title, name: nationality.name.to_title)
    end
    result.unshift(NationalityOption.new(id: "", name: ""))
    result
  end
end
