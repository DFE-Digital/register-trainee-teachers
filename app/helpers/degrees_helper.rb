# frozen_string_literal: true

module DegreesHelper
  include ApplicationHelper

  def degree_type_options
    to_enhanced_options(Degrees::DfEReference::TYPES.all) do |ref_data|
      synonyms = Array(ref_data[:match_synonyms]) + Array(ref_data[:suggestion_synonyms]) + Array(ref_data[:abbreviation])
      data = {
        "data-synonyms" => synonyms.join("|"),
        "data-append" => ref_data[:abbreviation] && tag.strong("(#{ref_data[:abbreviation]})"),
        "data-boost" => (Degrees::DfEReference::COMMON_TYPES.include?(ref_data[:name]) ? 1.5 : 1),
        "data-hint" => ref_data[:hint] && tag.span(ref_data[:hint], class: "autocomplete__option--hint"),
      }.compact
      [ref_data[:name], ref_data[:name], data]
    end
  end

  def institutions_options
    to_enhanced_options(Degrees::DfEReference::INSTITUTIONS.all) do |ref_data|
      [ref_data[:name],
       ref_data[:name],
       { "data-synonyms" => (Array(ref_data[:match_synonyms]) + Array(ref_data[:suggestion_synonyms])).join("|") }]
    end
  end

  def subjects_options
    to_enhanced_options(Degrees::DfEReference::SUBJECTS.all) do |ref_data|
      [ref_data[:name],
       ref_data[:name],
       { "data-synonyms" => (Array(ref_data[:match_synonyms]) + Array(ref_data[:suggestion_synonyms])).join("|") }]
    end
  end

  def grade_options(trainee)
    if current_user.system_admin? && trainee.hesa_record?
      Degrees::DfEReference::GRADES
    else
      Degrees::DfEReference::SUPPORTED_GRADES_WITH_OTHER
    end
  end

  def countries_options
    to_options(Dttp::CodeSets::Countries::MAPPING.keys)
  end

  def path_for_degrees(trainee)
    return trainee_degrees_new_type_path(trainee) if trainee.degrees.empty?

    trainee_degrees_confirm_path(trainee)
  end
end
