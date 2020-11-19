# frozen_string_literal: true

module DegreesHelper
  include ApplicationHelper

  def hesa_degree_types_options
    to_options(hesa_degree_types)
  end

  def institutions_options
    to_options(institutions)
  end

  def subjects_options
    to_options(subjects)
  end

  def countries_options
    to_options(countries)
  end

private

  def hesa_degree_types
    HESA_DEGREE_TYPES.map do |_hesa_code, _abbreviation, name, _level|
      name
    end
  end

  def institutions
    INSTITUTIONS
  end

  def subjects
    SUBJECTS
  end

  def countries
    COUNTRIES
  end
end
