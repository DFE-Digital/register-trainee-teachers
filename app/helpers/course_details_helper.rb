# frozen_string_literal: true

module CourseDetailsHelper
  include ApplicationHelper

  def course_subjects_options
    to_options(course_subjects)
  end

  def filter_course_subjects_options
    to_options(course_subjects, first_value: "All subjects")
  end

  def main_age_ranges_options
    age_ranges(option: :main)
  end

  def additional_age_ranges_options
    to_options(age_ranges(option: :additional))
  end

private

  def age_ranges(option:)
    Dttp::CodeSets::AgeRanges::MAPPING.select { |_, attributes| attributes[:option] == option }.keys.map do |age_range|
      age_range.join(" to ")
    end
  end

  def course_subjects
    Dttp::CodeSets::CourseSubjects::MAPPING.keys
  end
end
