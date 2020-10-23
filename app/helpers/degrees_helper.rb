module DegreesHelper
  def hesa_degree_types_options
    boilerplate(hesa_degree_types)
  end

  def institutions_options
    boilerplate(institutions)
  end

  def degree_subjects_options
    boilerplate(degree_subjects)
  end

  def degree_countries_options
    boilerplate(degree_countries)
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

  def degree_subjects
    DEGREE_SUBJECTS
  end

  def degree_countries
    DEGREE_COUNTRIES
  end

  def boilerplate(array)
    result = array.map do |name|
      OpenStruct.new(name: name)
    end
    result.unshift(OpenStruct.new(name: nil))
    result
  end
end
