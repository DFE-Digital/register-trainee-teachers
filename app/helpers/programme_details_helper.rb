# frozen_string_literal: true

module ProgrammeDetailsHelper
  include ApplicationHelper

  def programme_subjects_options
    to_options(programme_subjects)
  end

  def filter_programme_subjects_options
    to_options(programme_subjects, first_value: "All subjects")
  end

  def main_age_ranges_options
    age_ranges(option: :main)
  end

  def additional_age_ranges_options
    to_options(age_ranges(option: :additional))
  end

private

  def age_ranges(option:)
    Dttp::CodeSets::AgeRanges::MAPPING.select { |_, attributes| attributes[:option] == option }.keys
  end

  def programme_subjects
    Dttp::CodeSets::ProgrammeSubjects::MAPPING.keys
  end
end
