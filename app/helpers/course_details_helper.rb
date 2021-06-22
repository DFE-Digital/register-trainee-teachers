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

  def route_title(route)
    t("views.forms.publish_course_details.route_titles.#{route}")
  end

  def subjects_for_summary_view(subject_one, subject_two, subject_three)
    additional_subjects = [subject_two, subject_three].reject(&:blank?).join(" and ")

    [subject_one&.upcase_first, additional_subjects].reject(&:blank?).join(" with ")
  end

private

  def age_ranges(option:)
    Dttp::CodeSets::AgeRanges::MAPPING.select { |_, attributes| attributes[:option] == option }.keys.map do |age_range|
      age_range.join(" to ")
    end
  end

  def course_subjects
    @course_subjects ||= begin
      return Dttp::CodeSets::CourseSubjects::MAPPING.keys unless FeatureService.enabled?(:use_subject_specialisms)

      SubjectSpecialism.pluck(:name)
    end
  end
end
