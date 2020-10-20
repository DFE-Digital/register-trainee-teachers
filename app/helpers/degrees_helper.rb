module DegreesHelper
  def hesa_degrees
    hesa_degree_types_name = HESA_DEGREE_TYPES.map do |_hesa_code, _abbreviation, name, _level|
      name
    end
    boilerplate(hesa_degree_types_name)
  end

  def institutions
    boilerplate(INSTITUTIONS)
  end

  def degree_subjects
    boilerplate(DEGREE_SUBJECTS)
  end

  def degree_countries
    boilerplate(DEGREE_COUNTRIES)
  end

private

  def boilerplate(array)
    result = array.map do |name|
      OpenStruct.new(name: name)
    end
    result.unshift(OpenStruct.new(name: nil))
    result
  end
end
