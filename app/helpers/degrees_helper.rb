# frozen_string_literal: true

module DegreesHelper
  include ApplicationHelper

  def degree_type_options
    to_enhanced_options(degree_type_data) do |ref_data|
      synonyms = Array(ref_data[:match_synonyms]) + Array(ref_data[:suggestion_synonyms]) + Array(ref_data[:abbreviation])
      data = {
        "data-synonyms" => synonyms.join("|"),
        "data-append" => ref_data[:abbreviation] && tag.strong("(#{ref_data[:abbreviation]})"),
        "data-boost" => (Degree::COMMON_TYPES.include?(ref_data[:name]) ? 1.5 : 1),
        "data-hint" => ref_data[:hint] && tag.span(ref_data[:hint], class: "autocomplete__option--hint"),
      }.compact
      [ref_data[:name], ref_data[:name], data]
    end
  end

  def institutions_options
    to_enhanced_options(institution_data) do |ref_data|
      [ref_data[:name],
       ref_data[:name],
       { "data-synonyms" => (Array(ref_data[:match_synonyms]) + Array(ref_data[:suggestion_synonyms])).join("|") }]
    end
  end

  def subjects_options
    to_enhanced_options(subject_data) do |ref_data|
      [ref_data[:name],
       ref_data[:name],
       { "data-synonyms" => (Array(ref_data[:match_synonyms]) + Array(ref_data[:suggestion_synonyms])).join("|") }]
    end
  end

  def countries_options
    to_options(countries)
  end

  def grades
    Degree::GRADES
  end

  def path_for_degrees(trainee)
    return trainee_degrees_new_type_path(trainee) if trainee.degrees.empty?

    trainee_degrees_confirm_path(trainee)
  end

private

  def institution_data
    DfE::ReferenceData::TweakedReferenceList.new(
      DfE::ReferenceData::Degrees::INSTITUTIONS,
      {
        "96e9359f-dbad-4486-8de9-f05f3c7104c2" => { name: "Other", match_synonyms: [], suggestion_synonyms: [], abbreviation: nil },
      },
    ).all
  end

  def subject_data
    DfE::ReferenceData::Degrees::SINGLE_SUBJECTS.all
  end

  def degree_type_data
    DfE::ReferenceData::Degrees::TYPES_INCLUDING_GENERICS.all
  end

  def countries
    Dttp::CodeSets::Countries::MAPPING.keys
  end
end
