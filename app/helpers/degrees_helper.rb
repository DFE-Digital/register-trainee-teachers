module DegreesHelper
  include ApplicationHelper
  def hesa_degree_types_options
    boilerplate(hesa_degree_types)
  end

  def institutions_options
    boilerplate(institutions)
  end

  def subjects_options
    boilerplate(subjects)
  end

  def countries_options
    boilerplate(countries)
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
