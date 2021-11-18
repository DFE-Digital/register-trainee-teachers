# frozen_string_literal: true

module DegreesHelper
  include ApplicationHelper

  def degree_type_options
    to_enhanced_options(degree_type_data) do |name, attributes|
      synonyms = (attributes[:synonyms] || []) << attributes[:abbreviation]
      data = {
        "data-synonyms" => synonyms.join("|"),
        "data-append" => attributes[:abbreviation] && tag.strong("(#{attributes[:abbreviation]})"),
        "data-boost" => (Dttp::CodeSets::DegreeTypes::COMMON.include?(name) ? 1.5 : 1),
      }
      [name, name, data]
    end
  end

  def institutions_options
    to_enhanced_options(institution_data) do |name, attributes|
      [name, name, { "data-synonyms" => (attributes[:synonyms] || []).join("|") }]
    end
  end

  def subjects_options
    to_enhanced_options(subject_data) do |name, attributes|
      [name, name, { "data-synonyms" => (attributes[:synonyms] || []).join("|") }]
    end
  end

  def countries_options
    to_options(countries)
  end

  def grades
    Dttp::CodeSets::Grades::MAPPING.keys
  end

  def path_for_degrees(trainee)
    return trainee_degrees_new_type_path(trainee) if trainee.degrees.empty?

    trainee_degrees_confirm_path(trainee)
  end

private

  def institution_data
    Dttp::CodeSets::Institutions::MAPPING
  end

  def subject_data
    Dttp::CodeSets::DegreeSubjects::MAPPING
  end

  def degree_type_data
    Dttp::CodeSets::DegreeTypes::MAPPING
  end

  def countries
    Dttp::CodeSets::Countries::MAPPING.keys
  end
end
