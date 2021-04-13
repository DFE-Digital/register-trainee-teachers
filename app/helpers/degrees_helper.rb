# frozen_string_literal: true

module DegreesHelper
  include ApplicationHelper

  def hesa_degree_types_options
    options = [OpenStruct.new(option_name: nil, option_value: nil)]
    Dttp::CodeSets::DegreeTypes::MAPPING.each do |key, value|
      unless Dttp::CodeSets::DegreeTypes::NON_UK.include?(key)
        name_with_abbreviation = value[:abbreviation] ? "#{key} (#{value[:abbreviation]})" : key
        options << OpenStruct.new(option_name: name_with_abbreviation, option_value: key)
      end
    end
    options
  end

  def enhanced_degree_type_options
    Dttp::CodeSets::DegreeTypes::MAPPING.map do |name, attributes|
      data = {
        # If you have multiple synonyms, you can provide them as a string, separated by |
        # e.g. "PhD|Doctor of Philosophy".
        "data-synonyms" => attributes[:abbreviation],
        # Currently, this is a presentational attribute (the bit in brackets),
        # but could also be searchable.
        "data-alt" => attributes[:abbreviation],
        # Here we could have other attrs like 'data-hint', 'data-typos' etc
      }
      [name, name, data]
    end
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
