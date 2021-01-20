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

  def grades
    Dttp::CodeSets::Grades::MAPPING.keys
  end

private

  def hesa_degree_types
    Dttp::CodeSets::DegreeTypes::MAPPING.keys - Dttp::CodeSets::DegreeTypes::NON_UK
  end

  def institutions
    Dttp::CodeSets::Institutions::MAPPING.keys
  end

  def subjects
    Dttp::CodeSets::DegreeSubjects::MAPPING.keys
  end

  def countries
    Dttp::CodeSets::Countries::MAPPING.keys
  end
end
